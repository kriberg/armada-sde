# -*- coding: utf-8 -*-
import os
from django.test import TestCase, override_settings
from armada_sde import models as sde_models
from importlib import reload


class LoadSDEModelsTests(TestCase):
    def setUp(self):
        self._settings = os.environ.get('DJANGO_SETTINGS_MODULE')
        os.environ['DJANGO_SETTINGS_MODULE'] = 'tests.settings'

    def tearDown(self):
        if self._settings:
            os.environ['DJANGO_SETTINGS_MODULE'] = self._settings

    def test_models(self):
        reload(sde_models)
        imported_models = dir(sde_models)
        for model_name in ('InvType',
                           'StaStation',
                           'ChrFaction',
                           'MapDenormalize'):
            self.assertIn(model_name, imported_models)

    @override_settings(ARMADA={'SDE': {'module': 'tests.testapp.models'}})
    def test_custom_models_module(self):
        reload(sde_models)
        imported_models = dir(sde_models)

        self.assertIn('CertCert', imported_models)
        for model_name in ('InvType',
                           'StaStation',
                           'ChrFaction',
                           'MapDenormalize'):
            self.assertNotIn(model_name, imported_models)
