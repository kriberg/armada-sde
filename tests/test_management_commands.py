# -*- coding: utf-8 -*-
import os
from django.test import TransactionTestCase, override_settings
from django.test.utils import captured_stdout
from django.db import DEFAULT_DB_ALIAS
from django.core.management import call_command
from . import run_sql


class LoadSDECommandTests(TransactionTestCase):
    def setUp(self):
        self.project_root = os.path.join('tests', 'testapp')
        self._settings = os.environ.get('DJANGO_SETTINGS_MODULE')
        os.environ['DJANGO_SETTINGS_MODULE'] = 'tests.settings'

        run_sql(DEFAULT_DB_ALIAS,
                os.path.join(self.project_root,
                             'fixtures',
                             'sde_ddl.sql'))

    def tearDown(self):
        if self._settings:
            os.environ['DJANGO_SETTINGS_MODULE'] = self._settings

    def test_import_sde_command(self):
        with captured_stdout() as stdout:
            call_command('pg_import_sde', '-s')
        output = stdout.getvalue()
        self.assertIn('Renamed invTypes to sde_invTypes', output, msg=output)

    def test_generate_models_command(self):
        run_sql(DEFAULT_DB_ALIAS,
                os.path.join(self.project_root,
                             'fixtures',
                             'rename_tables.sql'))
        with captured_stdout() as stdout:
            call_command('pg_generate_models')
        output = stdout.getvalue()
        self.assertIn('# Generated', output, msg=output)
        self.assertIn('class InvType(models.Model)', output, msg=output)
        self.assertIn('db_table = \'sde_invTypes\'', output, msg=output)

    @override_settings(ARMADA={'SDE': {'schema': 'sde'}})
    def test_move_sde_command(self):
        run_sql(DEFAULT_DB_ALIAS,
                os.path.join(self.project_root,
                             'fixtures',
                             'rename_tables.sql'))
        with captured_stdout() as stdout:
            call_command('pg_move_sde')
        output = stdout.getvalue()
        self.assertIn('Moving SDE tables to sde schema...', output, msg=output)
        self.assertIn('Moving evesde.sde_invTypes -> sde.sde_invTypes', output,
                      msg=output)
        self.assertIn('Adding index for primary key column to table '
                      'sde_industryActivityMaterials', output, msg=output)
