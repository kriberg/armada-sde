# armada-sde

[![Build Status](https://travis-ci.org/kriberg/armada-sde.svg?branch=master)](https://travis-ci.org/kriberg/armada-sde)
[![Coverage Status](https://coveralls.io/repos/github/kriberg/armada-sde/badge.svg?branch=master)](https://coveralls.io/github/kriberg/armada-sde?branch=master)

armada-sde is a pluggable app for Django which provides models and tools for using Fuzzysteve's PostgreSQL dumps. Its
design allows you to automate upgrades of the SDE data and generate new models for any tables contained therein. 

## Usage

Grab the latest version of armada-sde directly from PyPI:

```commandline
pip install armada-sde
```

Add it to Django's `settings.py`:

```python
INSTALLED_APPS = [
    # ...
    'armada_sde',
]
```

Download Fuzzysteve's [latest schema dump](https://www.fuzzwork.co.uk/dump/postgres-schema-latest.dmp.bz2) for postgres and unpack:

```commandline
wget https://www.fuzzwork.co.uk/dump/postgres-schema-latest.dmp.bz2
bunzip2 postgres-schema-latest.dmp.bz2
```

Import the dump

```commandline
python manage.py pg_import_sde -f postgres-schema-latest.dmp
```

If you want to handle the importing yourself, run `pg_import_sde` with `-s` and no `-f`. This will rename the tables, 
so to better fit with Django best practices.

After import, the tables needs to be moved from the evesde schema to the public schema:

```commandline
python manage.py pg_move_sde
```

You should now be able to import models and use them:

```python
from django.db import models
from armada_sde.models import InvType

# Trit for the trit god
trit = InvType.objects.get(name='Tritanium')

# Use it in your models

class ShoppingListItem(models.Model):
    quantity = models.IntegerField(default=1)
    item = models.ForeignKey(InvType, on_delete=models.DO_NOTHING)
```

## Advanced usage

### Generate models
armada_sde comes with a stock set of models which is generated automatically through a customized version of Django's
inspectdb command. You can generate your own set of models and do your own alterations, if you like. First, import the
dump as previously described, so it is present in the evesde schema. Then you can generate a models file:

```commandline
python manage.py pg_generate_models -o project/myapp/models.py
```
After generation, move the tables into the public schema and generate primary keys, with the `pg_move_sde` command. 
You can now do any alterations you like. If you would like to generate migrations for your models, remove 
`managed = False` from the Meta class.

If you want, you can also ensure compatibility with other pluggable apps that use the SDE models, by configuring 
armada_sde to load your custom variants instead of the stock models. Add this to your `settings.py`:
 
```python
ARMADA = {
    'SDE': {
        'module': 'project.myapp.models'
    }
}
```

Any other app importing models from `armada_sde.models`, will instead be loading your custom models from your project.

### Using a custom schema for the SDE

If you are sharing a database between several projects, it might be handy to have a shared schema for the SDE. You can 
configure armada-sde to use a custom destination schema for tables, instead of moving them from evesde into public.

To achieve this, set these parameters in `settings.py`:

```python
ARMADA = {
    'SDE': {
        'schema': '<your_sde_schema>'
    }
}
```

It is not a good idea to use the evesde schema as your custom schema, as it might give you issues when upgrading the 
SDE. 
