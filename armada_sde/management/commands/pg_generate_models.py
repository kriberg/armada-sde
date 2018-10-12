from __future__ import unicode_literals
from __future__ import print_function
import sys
import ast
import autopep8
import keyword
import re
from collections import OrderedDict
from traceback import format_exc
from django.conf import settings
from django.core.management.commands.inspectdb import Command as Inspect
from django.db import connections
from django.utils.encoding import force_text
from django.db.models.constants import LOOKUP_SEP
from django.utils import timezone
from armada_sde.settings import SDE_SCHEMA
from armada_sde import __version__


FK_OVERRIDE = {
    'typeID': 'sde_invTypes',
    'solarSystemID': 'sde_mapSolarSystems',
    'categoryID': 'sde_invCategories',
    'itemID': 'sde_invItems',
    'locationID': 'sde_mapDenormalize',
    'attributeID': 'sde_dgmAttributeTypes',
    'activityID': 'sde_ramActivities',
}

# There are some tables which have colliding FK names to other tables
# We override those here. Setting it to None will skip creating FK and not
# define the model field as ForeignKey.
# Using a tuple, will override the target table for this specific source table
TABLE_FK_OVERRIDE = {
    'sde_chrAncestries': {
        'iconID': None
    },
    'sde_invTypes': {
        'graphicID': None
    },
    'sde_crpNPCCorporations': {
        'solarSystemID': None
    },
    'sde_dgmAttributeTypes': {
        'categoryID': None,
    },
    'sde_industryActivityMaterials': {
        'typeID': None
    },
    'sde_industryActivityProbabilities': {
        'typeID': None
    },
    'sde_industryActivitySkills': {
        'typeID': None
    },
    'sde_industryActivityProducts': {
        'typeID': None,
    },
    'sde_invItems': {
        'typeID': None,
        'locationID': None,
    },
    'sde_staOperations': {
        'activityID': ('sde_crpActivities', 'activityID')
    },
    'sde_chrFactions': {
        'corporationID': None,
    }
}


class Command(Inspect):
    help = ('Generates SDE models from tables in the evesde schema.')
    requires_model_validation = False
    requires_system_checks = False

    def add_arguments(self, parser):
        parser.add_argument('-d', '--dbalias', action='store', dest='database',
                            default='default',
                            help='Database alias defined in your project '
                                 'settings to load the SDE into. Defaults '
                                 'to \'default\'')
        parser.add_argument('-o', '--output', action='store', dest='output',
                            default='-',
                            help='Destination file for the model definitions. '
                                 'Models will be printed to stdout if this is '
                                 'omitted.')

    def __init__(self, *args, **kwargs):
        super(Command, self).__init__(*args, **kwargs)
        self.table2model_mapping = {}
        self.table_pk_mapping = {}
        self.foreign_keys = []
        try:
            self.sde_schema = settings.ARMADA['SDE']['schema']
        except (KeyError, AttributeError):
            self.sde_schema = SDE_SCHEMA

    def generate_pk_mapping(self, dbalias):
        connection = connections[dbalias]

        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde')
            for table_name in connection.introspection.table_names(cursor):
                constraints = connection.introspection.get_constraints(
                    cursor, table_name)
                for name, spec in constraints.items():
                    if spec.get('primary_key'):
                        pk_columns = spec.get('columns')
                        # Tables with compound keys are not linked to, so
                        # we skip adding these.
                        if isinstance(pk_columns, list) \
                            and len(pk_columns) > 1:
                            continue
                        elif isinstance(pk_columns, list) \
                            and len(pk_columns) == 1:
                            column_name = pk_columns[0]
                            if column_name in self.table_pk_mapping \
                                    and column_name not in FK_OVERRIDE:
                                self.stderr.write(f'{column_name} already present! pointing to {self.table_pk_mapping[column_name]}, not adding {table_name}')
                            else:
                                self.table_pk_mapping[column_name] = table_name
        self.table_pk_mapping.update(FK_OVERRIDE)

    def generate_foreign_keys(self, dbalias):
        connection = connections[dbalias]
        ispect = connection.introspection
        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde')
            for source, target, column_name in self.foreign_keys:
                target_pk = ispect.get_primary_key_column(cursor, target)
                sql = '''ALTER TABLE evesde."{0}" 
                DROP CONSTRAINT IF EXISTS "{0}_{1}_fkey",
                ADD CONSTRAINT "{0}_{1}_fkey" 
                    FOREIGN KEY ("{2}") 
                    REFERENCES evesde."{1}" ("{3}") 
                    DEFERRABLE INITIALLY DEFERRED;'''.format(source,
                                                             target,
                                                             column_name,
                                                             target_pk)
                try:
                    cursor.execute(sql)
                except Exception as ex:
                    self.stdout.write('Skipping ' + sql + '\n' + str(ex))

    def handle(self, *args, **options):
        dbalias = options['database']
        output_filename = options.get('output')
        model_lines = []

        self.generate_pk_mapping(dbalias)

        connection = connections[dbalias]
        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde;')
            for name in connection.introspection.table_names(cursor):
                if not len(name) > 1:
                    continue
                self.table2model_mapping[name] = self.table2model(
                    name[4].upper() + name[5:])

            for line in self.handle_inspection(dbalias):
                model_lines.append(line)

        self.generate_foreign_keys(dbalias)

        model_code = autopep8.fix_code('\n'.join(model_lines),
                                       options={
                                           'aggressive': 2,
                                           'experimental': True
                                       })
        try:
            ast.parse(model_code)
            if output_filename == '-':
                self.stdout.write(model_code)
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
        sde_tables = []

        def strip_prefix(s):
            return s[1:] if s.startswith("u'") else s

        with connection.cursor() as cursor:
            cursor.execute('SET search_path TO evesde;')
            yield "# This is an auto-generated Django models.py file."
            yield "# It was made by armada_sde's pg_load_sde which has special"
            yield "# seasoning for importing the SDE dumps generated for " \
                  "postgresql."
            yield "# Generated {}, version {}".format(
                timezone.now().isoformat(),
                __version__
            )
            yield 'from __future__ import unicode_literals'
            yield 'from %s import models' % self.db_module

            known_models = []
            ispect = connection.introspection
            tables_to_introspect = ispect.table_names(cursor)

            for renamed_table_name in tables_to_introspect:
                suitable_str = None
                sde_tables.append(renamed_table_name)

                try:

                    relations = ispect.get_relations(cursor,
                                                     renamed_table_name)
                    constraints = ispect.get_constraints(cursor,
                                                         renamed_table_name)
                    pk_column_name = ispect.get_primary_key_column(
                        cursor, renamed_table_name)

                    unique_columns = [
                        c['columns'][0] for c in list(constraints.values())
                        if c['unique'] and len(c['columns']) == 1
                    ]
                    table_description = ispect.get_table_description(
                        cursor, renamed_table_name)
                except Exception as e:
                    yield "# Unable to inspect table '%s'" % renamed_table_name
                    yield "# The error was: %s" % force_text(e)
                    continue
                model_name = self.table2model_mapping[renamed_table_name]
                yield ''
                yield ''
                yield 'class %s(models.Model):' % model_name
                known_models.append(model_name)
                # Holds column names used in the table so far
                used_column_names = []
                # Maps column names to names of model fields
                column_to_field_name = {}

                for row in table_description:
                    # Holds Field notes, to be displayed in a Python comment.
                    comment_notes = []
                    # Holds Field parameters such as 'db_column'.
                    extra_params = OrderedDict()
                    column_name = row[0]
                    is_relation = column_name in relations

                    att_name, params, notes = self.normalize_col_name(
                        column_name, used_column_names, is_relation)
                    extra_params.update(params)
                    comment_notes.extend(notes)

                    used_column_names.append(att_name)
                    column_to_field_name[column_name] = att_name

                    fk_override = TABLE_FK_OVERRIDE.get(
                        renamed_table_name, {}).get(column_name)
                    skip_fk = False
                    if renamed_table_name in TABLE_FK_OVERRIDE:
                        if column_name in TABLE_FK_OVERRIDE[renamed_table_name]:
                            if TABLE_FK_OVERRIDE[renamed_table_name][column_name] is None:
                                skip_fk = True

                    # Add primary_key and unique, if necessary.
                    if column_name == pk_column_name:
                        extra_params['primary_key'] = True
                    elif column_name in unique_columns:
                        extra_params['unique'] = True

                    if column_name in self.table_pk_mapping and \
                        column_name != pk_column_name and \
                            not skip_fk:
                        # This where we put on our placement hat and try our
                        # best to generate foreign keys
                        if fk_override:
                            target_table = fk_override[0]
                        else:
                            target_table = self.table_pk_mapping[column_name]

                        target_model = self.table2model_mapping[target_table]
                        if att_name.endswith('_id'):
                            att_name = att_name[:-3]
                            column_to_field_name[column_name] = att_name
                        field_type = "ForeignKey('%s'" % target_model
                        self.foreign_keys.append(
                            (renamed_table_name, target_table, column_name)
                        )
                    else:
                        # Calling `get_field_type` to get the field type string
                        # and any additional parameters and notes.
                        field_type, field_params, field_notes \
                            = self.get_field_type(connection,
                                                  renamed_table_name,
                                                  row)
                        extra_params.update(field_params)
                        comment_notes.extend(field_notes)

                        field_type += '('

                    # Don't output 'id = meta.AutoField(primary_key=True)',
                    # because that's assumed if it doesn't exist.
                    if att_name == 'id' \
                            and extra_params == {'primary_key': True}:
                        if field_type == 'AutoField(':
                            continue
                        elif field_type == 'IntegerField(' and not \
                                connection.features.can_introspect_autofield:
                            comment_notes.append('AutoField?')

                    # Add 'null' and 'blank', if the 'null_ok' flag was present
                    # in the table description.
                    if row[6]:  # If it's NULL...
                        if field_type == 'BooleanField(':
                            field_type = 'NullBooleanField('
                        else:
                            extra_params['blank'] = True
                            extra_params['null'] = True

                    field_desc = '%s = %s%s' % (
                        att_name,
                        # Custom fields will have a dotted path
                        '' if '.' in field_type else 'models.',
                        field_type,
                    )
                    if field_type.startswith('ForeignKey('):
                        field_desc += ', on_delete=models.DO_NOTHING'

                    if extra_params:
                        if not field_desc.endswith('('):
                            field_desc += ', '
                        field_desc += ', '.join(
                            '%s=%s' % (k, strip_prefix(repr(v)))
                            for k, v in list(extra_params.items()))
                    field_desc += ')'
                    if comment_notes:
                        field_desc += '  # ' + ' '.join(comment_notes)
                    if column_name.lower() == '{}name'.format(
                            model_name[3:].lower()):
                        suitable_str = att_name
                    yield '    %s' % field_desc
                yield ''
                yield '    @staticmethod'
                yield '    def get_pk_field():'
                if not pk_column_name:
                    yield '        return \'id\''
                    yield ''
                    yield ('    id = models.IntegerField(primary_key=True) '
                           '# Autogenerated substitute primary key')
                else:
                    yield '        return \'%s\'' % \
                          column_to_field_name[pk_column_name]
                if suitable_str:
                    yield ''
                    yield '    def __str__(self):'
                    yield '        return self.%s' % suitable_str
                    yield ''
                    yield '    @staticmethod'
                    yield '    def get_name_field():'
                    yield '        return \'%s\'' % suitable_str
                else:
                    yield ''
                    yield '    @staticmethod'
                    yield '    def get_name_field():'
                    yield '        return None'
                yield ''
                for meta_line in self.get_meta_class(renamed_table_name,
                                                     constraints,
                                                     column_to_field_name):
                    yield meta_line

    @staticmethod
    def get_meta_class(table_name, constraints, column_to_field_name):
        """
        Return a sequence comprising the lines of code necessary
        to construct the inner Meta class for the model corresponding
        to the given database table name.
        """
        unique_together = []
        for index, params in list(constraints.items()):
            if params['unique']:
                columns = params['columns']
                if len(columns) > 1:
                    # we do not want to include the u"" or u'' prefix
                    # so we build the string rather than interpolate the tuple
                    tup = '(' + ', '.join(
                        "'%s'" % column_to_field_name[c] for c in columns) + ')'
                    unique_together.append(tup)
        verbose_name = re.sub('([a-z])([A-Z])', r'\1 \2', table_name)
        if verbose_name.startswith('sde_'):
            verbose_name = verbose_name[4:].title()
        meta = ["",
                "    class Meta(object):",
                "        managed = False",
                "        verbose_name = %r" % verbose_name.title(),
                "        db_table = '%s'" % table_name]
        if unique_together:
            tup = '(' + ', '.join(unique_together) + ',)'
            meta += ["        unique_together = %s" % tup]
        return meta

    def normalize_col_name(self, col_name, used_column_names, is_relation):
        """
        Modify the column name to make it Python-compatible as a field name
        """
        field_params = {}
        field_notes = []

        new_name = re.sub('([a-z])([A-Z])', r'\1_\2', col_name).lower()

        if is_relation:
            if new_name.endswith('_id'):
                new_name = new_name[:-3]
            else:
                field_params['db_column'] = col_name

        new_name, num_repl = re.subn(r'\W', '_', new_name)
        if num_repl > 0:
            field_notes.append('Field renamed to remove unsuitable characters.')

        if new_name.find(LOOKUP_SEP) >= 0:
            while new_name.find(LOOKUP_SEP) >= 0:
                new_name = new_name.replace(LOOKUP_SEP, '_')
            if col_name.lower().find(LOOKUP_SEP) >= 0:
                # Only add the comment if the double underscore was in
                # the original name
                field_notes.append("Field renamed because it contained more "
                                   "than one '_' in a row.")

        if new_name.startswith('_'):
            new_name = 'field%s' % new_name
            field_notes.append("Field renamed because it started with '_'.")

        if new_name.endswith('_'):
            new_name = '%sfield' % new_name
            field_notes.append("Field renamed because it ended with '_'.")

        if keyword.iskeyword(new_name):
            new_name += '_field'
            field_notes.append(
                'Field renamed because it was a Python reserved word.')

        if new_name[0].isdigit():
            new_name = 'number_%s' % new_name
            field_notes.append(
                "Field renamed because it wasn't a valid Python identifier.")

        if new_name in used_column_names:
            num = 0
            while '%s_%d' % (new_name, num) in used_column_names:
                num += 1
            new_name = '%s_%d' % (new_name, num)
            field_notes.append('Field renamed because of name conflict.')

        if col_name != new_name:
            field_params['db_column'] = col_name

        return new_name, field_params, field_notes
