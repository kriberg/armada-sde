from __future__ import unicode_literals
from __future__ import print_function
import shlex
import sys
from subprocess import PIPE, Popen
from django.conf import settings
from django.db import connections
from django.core.management import BaseCommand


class Command(BaseCommand):
    help = ('(Re)Loads a new SDE dump from Fuzzysteve\'s SDE dump site into '
            'the database.')
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
        parser.add_argument('-s', '--skip-import', action='store_true',
                            dest='skip',
                            help='Skip importing the dump, just rename tables')

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

            self.stdout.write('Dropping the evesde schema, if exists...')
            cursor.execute("DROP SCHEMA IF EXISTS evesde CASCADE;")
            self.stdout.write('[DONE]\n')

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
            self.stdout.write(str(p.stdout.read(), 'utf-8'))
            self.stdout.flush()
            self.stderr.write(str(p.stderr.read(), 'utf-8'))
            self.stderr.flush()
            sys.exit(returncode)
        sys.stdout.write('[DONE]\n')

    def rename_tables(self, dbalias):
        connection = connections[dbalias]
        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde;')
            ispect = connection.introspection
            tables_to_introspect = ispect.table_names(cursor)

            for table_name in tables_to_introspect:
                renamed_table_name = 'sde_{}'.format(table_name)
                cursor.execute('DROP TABLE IF EXISTS evesde."{}";'.format(
                    renamed_table_name))
                cursor.execute('ALTER TABLE evesde."{}" '
                               'RENAME TO "{}";'.format(
                    table_name,
                    renamed_table_name))
                sys.stdout.write('Renamed {} to {}'.format(table_name,
                                                           renamed_table_name))

    def handle(self, *args, **options):
        dbalias = options['database']
        dump = options.get('file')
        skip = options.get('skip')

        if not skip and dump:
            self.import_database(dump, dbalias)
        self.rename_tables(dbalias)
