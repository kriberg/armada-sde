# -*- coding: utf-8 -*-
import os
from django.conf import settings

BASE_DIR = os.path.dirname(os.path.realpath(__file__))
ARMADA = getattr(settings, 'ARMADA', {})
SDE_CONFIG = ARMADA.get('SDE', {})
SDE_SCHEMA = SDE_CONFIG.get('schema', 'public')
SDE_MODULE = SDE_CONFIG.get('module', 'armada_sde.models.generated')
