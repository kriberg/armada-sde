# -*- coding: utf-8 -*-
import os
from django.test import TestCase, override_settings
from django.test.utils import captured_stdout
from django.db import DEFAULT_DB_ALIAS
from django.core.management import call_command
from . import run_sql


class LoadSDECommandTests(TestCase):
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

    def test_load_sde_command(self):
        with captured_stdout() as stdout:
            call_command('pg_load_sde')
        output = stdout.getvalue()
        self.assertIn('# Generated', output)
        self.assertIn('class InvType(models.Model)', output)

    @override_settings(ARMADA={'SDE': {'schema': 'sde'}})
    def test_load_sde_to_custom_schema(self):
        with captured_stdout() as stdout:
            call_command('pg_load_sde')
        output = stdout.getvalue()
        self.assertIn('Moving SDE tables to sde schema...', output)
        self.assertIn('Moving evesde.sde_invTypes -> sde.sde_invTypes', output)
        self.assertIn('Adding index for primary key column to table '
                      'sde_industryActivityMaterials', output)
