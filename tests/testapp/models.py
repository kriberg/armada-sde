from __future__ import unicode_literals
from django.db import models


class CertCert(models.Model):
    cert_id = models.IntegerField(db_column='certID', primary_key=True)
    description = models.TextField(blank=True, null=True)
    group_id = models.IntegerField(db_column='groupID', blank=True, null=True)
    name = models.CharField(max_length=255, blank=True, null=True)

    class Meta(object):
        managed = False
        verbose_name = 'Cert Certs'
        db_table = 'sde_certCerts'
