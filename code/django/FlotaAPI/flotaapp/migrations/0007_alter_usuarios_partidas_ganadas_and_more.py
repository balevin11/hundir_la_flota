# Generated by Django 4.0.10 on 2025-02-10 12:52

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('flotaapp', '0006_remove_barcospartida_hundido_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuarios',
            name='partidas_ganadas',
            field=models.FloatField(default=0),
        ),
        migrations.AlterField(
            model_name='usuarios',
            name='partidas_jugadas',
            field=models.FloatField(default=0),
        ),
    ]
