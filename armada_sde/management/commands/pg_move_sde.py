from __future__ import unicode_literals
from __future__ import print_function
import shlex
import sys
import ast
import autopep8
import keyword
import re
from collections import OrderedDict
from subprocess import PIPE, Popen
from traceback import format_exc
from django.conf import settings
from django.core.management.commands.inspectdb import Command as Inspect
from django.db import connections
from django.utils.encoding import force_text
from django.db.models.constants import LOOKUP_SEP
from django.utils import timezone
from armada_sde.settings import SDE_SCHEMA
from armada_sde import __version__


class Command(Inspect):
    help = ('(Re)Loads a new SDE dump from Fuzzysteve\'s SDE dump site into '
            'the database.')
    requires_model_validation = False
    requires_system_checks = False

    def add_arguments(self, parser):
        parser.add_argument('-d', '--dbalias', action='store', dest='database',
                            default='default',
                            help='Database alias defined in your project '
                                 'settings to load the SDE into. Defaults '
                                 'to \'default\'')
        parser.add_argument('-f', '--file', action='store', dest='file',
                            help='Fuzzysteve\'s postgres-schemas-latest dump '
                                 'file to use')
        parser.add_argument('-o', '--output', action='store', dest='output',
                            default='-',
                            help='Destination file for the model definitions. '
                                 'Models will be printed to stdout if this is '
                                 'omitted.')

    def __init__(self, *args, **kwargs):
        super(Command, self).__init__(*args, **kwargs)
        self.table2model_mapping = {}
        self.tables_for_fix = []
        try:
            self.sde_schema = settings.ARMADA['SDE']['schema']
        except (KeyError, AttributeError):
            self.sde_schema = SDE_SCHEMA

    def import_database(self, dump, dbalias):  # pragma: no cover
        connection = connections[dbalias]
        database = settings.DATABASES[dbalias]

        # Create the yaml user first, to supress some common errors. Then get
        # rid of any old SDE data.
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 FROM pg_roles WHERE rolname='yaml';")
            row = cursor.fetchone()
            try:
                row[0] == 1
            except (IndexError, TypeError):
                self.stdout.write('Creating the yaml user in the database...')
                cursor.execute('CREATE USER yaml')
                self.stdout.write('[DONE]\n')

            cursor.execute("DROP SCHEMA IF EXISTS evesde CASCADE;")

        params = ["pg_restore",
                  "-d",
                  database['NAME']]
        if database['USER']:
            params.append('-U')
            params.append(database['USER'])
        params.append(dump)

        sys.stdout.write('Starting import of database dump...')
        sys.stdout.flush()
        p = Popen(shlex.split(" ".join(params)),
                  stdin=PIPE,
                  stdout=PIPE,
                  stderr=PIPE,
                  shell=False)
        returncode = p.wait()
        if returncode != 0:
            sys.stdout.write('[FAILED]\n')
            self.stdout.write(p.stdout.read())
            self.stdout.flush()
            self.stderr.write(p.stderr.read())
            self.stderr.flush()
            sys.exit(returncode)
        sys.stdout.write('[DONE]\n')

    @staticmethod
    def generate_foreign_keys(dbalias):
        # primary_keys = {}
        connection = connections[dbalias]
        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde')
            for table_name in connection.introspection.table_names(cursor):
                _ = connection.introspection.get_constraints(cursor,
                                                             table_name)

    def handle(self, *args, **options):
        dbalias = options['database']
        output_filename = options.get('output')
        dump = options.get('file')
        model_lines = []

        if dump:  # pragma: no cover
            self.import_database(dump, dbalias)

        self.generate_foreign_keys(dbalias)

        connection = connections[dbalias]
        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde;')
            cursor.execute('CREATE SCHEMA IF NOT EXISTS {};'.format(
                self.sde_schema))
            for name in connection.introspection.table_names(cursor):
                if not len(name) > 1:
                    continue
                self.table2model_mapping[name] = self.table2model(
                    name[0].upper() + name[1:])

            for line in self.handle_inspection(dbalias):
                model_lines.append(line)

        model_code = autopep8.fix_code('\n'.join(model_lines))
        try:
            ast.parse(model_code)
            if output_filename == '-':
                self.stdout.write('model code ' + model_code)
            else:
                with open(output_filename, 'w') as output_file:
                    output_file.write(model_code)

            self.stdout.write('\nSDE loaded\n')
        except SyntaxError as ex:
            self.stderr.write('Could not parse generated models file:\n')
            self.stderr.write(format_exc(ex))
            sys.exit(-1)

    @staticmethod
    def table2model(n):
        if n.endswith('ies'):
            return n[:-3] + 'y'
        elif n.lower().endswith('classes'):
            return n[:-2]
        elif n.endswith('s'):
            return n[:-1]
        else:
            return n

    def handle_inspection(self, dbalias):
        connection = connections[dbalias]


        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde;')
            ispect = connection.introspection
            sde_tables = ispect.table_names(cursor)

            if self.sde_schema == 'evesde':
                self.stdout.write('Skipping move as schema is set to evesde')
                move_schema = False
            else:
                self.stdout.write('Moving SDE tables to {} schema...'.format(
                    self.sde_schema))
                move_schema = True

            for renamed_table_name in sde_tables:
                if move_schema:
                    cursor.execute('DROP TABLE IF EXISTS {}."{}";'.format(
                        self.sde_schema,
                        renamed_table_name
                    ))
                    self.stdout.write('Moving evesde.{0} -> {1}.{0}'.format(
                        renamed_table_name, self.sde_schema))
                    cursor.execute(
                        'ALTER TABLE evesde."{0}" SET SCHEMA {1}'.format(
                            renamed_table_name, self.sde_schema))

                pk_column_name = ispect.get_primary_key_column(
                    cursor, renamed_table_name)
                if pk_column_name is None:
                    pk = 'ALTER TABLE {}."{}" ADD COLUMN id SERIAL ' \
                         'NOT NULL;'.format(self.sde_schema, renamed_table_name)
                    idx = 'CREATE INDEX "{0}_id_idx" ON {1}."{0}" ' \
                          'USING btree(id);'.format(renamed_table_name,
                                                    self.sde_schema)
                    self.stdout.write('Adding non-composite primary key to '
                                      'table {}'.format(renamed_table_name))
                    cursor.execute(pk)
                    self.stdout.write('Adding index for primary key column to '
                                      'table {}'.format(renamed_table_name))
                    cursor.execute(idx)
            sys.stdout.write('All [DONE]\n')

