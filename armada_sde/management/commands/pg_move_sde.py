from __future__ import unicode_literals
from __future__ import print_function
import sys
from django.conf import settings
from django.core.management import BaseCommand
from django.db import connections
from armada_sde.settings import SDE_SCHEMA


class Command(BaseCommand):
    help = ('Moves tables from the evesde schema and into the public schema or'
            'your schema of choice. Afterwards, primary keys will be created '
            'for any table has compound keys.')
    requires_model_validation = False
    requires_system_checks = False

    def add_arguments(self, parser):
        parser.add_argument('-d', '--dbalias', action='store', dest='database',
                            default='default',
                            help='Database alias defined in your project '
                                 'settings to load the SDE into. Defaults '
                                 'to \'default\'')

    def __init__(self, *args, **kwargs):
        super(Command, self).__init__(*args, **kwargs)
        try:
            self.sde_schema = settings.ARMADA['SDE']['schema']
        except (KeyError, AttributeError):
            self.sde_schema = SDE_SCHEMA

    def handle(self, *args, **options):
        dbalias = options['database']
        self.move_tables(dbalias)

    def move_tables(self, dbalias):
        connection = connections[dbalias]

        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde;')
            cursor.execute('CREATE SCHEMA IF NOT EXISTS {};'.format(
                self.sde_schema))
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
