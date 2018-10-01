import os
import environ

INSTALLED_APPS = [
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.admin',
    'django.contrib.sessions',
    'django.contrib.staticfiles',
    'tests.testapp',
    'armada_sde',
]

TIME_ZONE = 'UTC'
USE_TZ = True
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
env = environ.Env()
environ.Env.read_env()
DEBUG = env('DEBUG', default=False)
SECRET_KEY = env('SECRET_KEY', default='hunter2')
DATABASES = {
    'default': env.db(default='psql://postgres@localhost/sde'),
}
CACHES = {
    'default': env.cache(default='dummycache://'),
}

ARMADA = {
    'SDE': {
        'schema': 'test'
    }
}
