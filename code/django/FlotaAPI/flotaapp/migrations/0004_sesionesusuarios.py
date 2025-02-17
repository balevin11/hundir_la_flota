# Generated by Django 4.0.10 on 2025-01-22 11:16

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('flotaapp', '0003_remove_emparejamiento_es_mutuo'),
    ]

    operations = [
        migrations.CreateModel(
            name='SesionesUsuarios',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('session_id', models.CharField(max_length=255, unique=True)),
                ('usuario', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='sesiones', to='flotaapp.usuarios')),
            ],
        ),
    ]
