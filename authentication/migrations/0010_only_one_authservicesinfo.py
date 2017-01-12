# -*- coding: utf-8 -*-
# Generated by Django 1.10.1 on 2017-01-07 06:47
from __future__ import unicode_literals

from django.db import migrations

def count_completed_fields(model):
    return len([True for key, value in model.__dict__.items() if bool(value)])

def forward(apps, schema_editor):
    # this ensures only one model exists per user
    AuthServicesInfo = apps.get_model('authentication', 'AuthServicesInfo')
    users = set([a.user for a in AuthServicesInfo.objects.all()])
    for u in users:
        auths = AuthServicesInfo.objects.filter(user=u)
        if auths.count() > 1:
            pk = auths[0].pk
            largest = 0
            for auth in auths:
                completed = count_completed_fields(auth)
                if completed > largest:
                    largest = completed
                    pk = auth.pk
            auths.exclude(pk=pk).delete()

    # ensure all users have a model
    User = apps.get_model('auth', 'User')
    for u in User.objects.exclude(pk__in=[user.pk for user in users]):
        AuthServicesInfo.objects.create(user=u)


class Migration(migrations.Migration):

    dependencies = [
        ('authentication', '0009_auto_20161021_0228'),
    ]

    operations = [
        migrations.RunPython(forward, migrations.RunPython.noop)
    ]
