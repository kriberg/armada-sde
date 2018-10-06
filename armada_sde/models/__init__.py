import sys
import inspect
from importlib import import_module
from django.db import models
from django.conf import settings
from armada_sde.settings import SDE_MODULE


__all__ = []

try:
    sde_module_name = settings.ARMADA['SDE']['module']
except (KeyError, AttributeError):
    sde_module_name = SDE_MODULE

if __name__ in sys.modules:
    for attribute in dir(sys.modules[__name__]):
        sde_class = getattr(sys.modules[__name__], attribute, None)
        if inspect.isclass(sde_class) and issubclass(sde_class,
                                                     models.Model):
            delattr(sys.modules[__name__], attribute)

sde_module = import_module(sde_module_name)
for name in dir(sde_module):
    sde_class = getattr(sde_module, name)
    if inspect.isclass(sde_class) and issubclass(sde_class, models.Model):
        setattr(sys.modules[__name__], name, sde_class)
        if not sde_class in __all__:
            __all__.append(sde_class)
