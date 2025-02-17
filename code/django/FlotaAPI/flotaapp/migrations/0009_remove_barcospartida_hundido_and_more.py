# Generated by Django 4.0.10 on 2025-02-11 09:44

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('flotaapp', '0008_barcospartida_hundido_usuarios_session_token_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='barcospartida',
            name='hundido',
        ),
        migrations.RemoveField(
            model_name='usuarios',
            name='session_token',
        ),
        migrations.AlterField(
            model_name='ataques',
            name='resultado',
            field=models.IntegerField(choices=[(0, 'Patrullero'), (1, 'Submarino'), (2, 'Destructor'), (3, 'Acorazado'), (4, 'Agua')]),
        ),
        migrations.AlterField(
            model_name='barcospartida',
            name='tipo_barco',
            field=models.IntegerField(choices=[(0, 'Patrullero'), (1, 'Submarino'), (2, 'Destructor'), (3, 'Acorazado')]),
        ),
    ]
