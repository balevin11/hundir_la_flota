from django.core.exceptions import ValidationError
from django.db import models


class Usuarios(models.Model):
    nombre = models.CharField(max_length=20, unique=True)
    contrasena = models.CharField(max_length=120)
    partidas_jugadas = models.FloatField(default=0)
    partidas_ganadas = models.FloatField(default=0)
    session_token = models.IntegerField(default=0)


class Partida(models.Model):
    DIFICULTADES = [
        ("F", "Fácil"),
        ("N", "Normal"),
        ("D", "Difícil")
    ]
    usuario1 = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="partidas_usuario1", null=True)
    usuario2 = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="partidas_usuario2", null=True)
    dificultad = models.CharField(max_length=1, choices=DIFICULTADES, default= "N")
    turno_actual = models.ForeignKey(Usuarios, null=True, blank=True, on_delete=models.SET_NULL, related_name="turno_actual")
    partida_terminada = models.BooleanField(default=False)
    ganador = models.ForeignKey(Usuarios, on_delete=models.SET_NULL, null=True, blank=True, related_name="partidas_ganador")

    def clean(self):
        if self.ganador and self.ganador not in [self.usuario1, self.usuario2]:
            raise ValidationError("The winner must be one of the two players in the game.")


class BarcosPartida(models.Model):
    DIRECCIONES = [
        ("H", "horizontal"),
        ("V", "vertical")
    ]
    class Barcos(models.IntegerChoices):
        PATRULLERO = 0
        DESTRUCTOR = 1
        SUBMARINO = 2
        ACORAZADO = 3
        PORTAAVIONES = 4

    partida = models.ForeignKey(Partida, on_delete=models.CASCADE, related_name="barcos_partida")
    jugador = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="barcos_jugador")
    X = models.IntegerField()
    Y = models.IntegerField()
    direccion = models.CharField(max_length=1, choices=DIRECCIONES, default= "V")
    tipo_barco = models.IntegerField(choices=Barcos.choices)
    # En principio no debería de estar --> puntos_dano = models.IntegerField()
    hundido = models.BooleanField(default=False)

    def longitud(self):
        if self.tipo_barco == 0:
            return 2
        elif self.tipo_barco == 1:
            return 3
        elif self.tipo_barco == 2:
            return 4
        elif self.tipo_barco == 3:
            return 5
        else:
            return 6


class Roca(models.Model):
    partida = models.ForeignKey(Partida, on_delete=models.CASCADE, related_name="roca_partida")
    X = models.IntegerField()
    Y = models.IntegerField()


class Ataques(models.Model):
    class Resultados(models.IntegerChoices):
        PATRULLERO = 0
        DESTRUCTOR = 1
        SUBMARINO = 2
        ACORAZADO = 3
        PORTAAVIONES = 4
        AGUA = 5

    partida = models.ForeignKey(Partida, on_delete=models.CASCADE, related_name="ataques_partida")
    atacante = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="ataques_atacante")
    objetivo = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="ataques_objetivo")
    X = models.IntegerField()
    Y = models.IntegerField()
    resultado = models.IntegerField(choices=Resultados.choices)


class Emparejamiento(models.Model):
    DIFICULTADES = [
        ("F", "Fácil"),
        ("N", "Normal"),
        ("D", "Difícil")
    ]
    usuario1 = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="emparejamiento_usuario1", null=True)
    usuario2 = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="emparejamiento_usuario2",null=True)
    dificultad = models.CharField(max_length=1, choices=DIFICULTADES, default= "N")

    def __str__(self):
        return f'{self.usuario1} emparejado con {self.usuario2} (Mutuo: {self.es_mutuo})'



class SesionesUsuarios(models.Model):
    usuario = models.ForeignKey(Usuarios, on_delete=models.CASCADE, related_name="sesiones")
    session_id = models.CharField(max_length=255, unique=True)

    def __str__(self):
        return f"Sesión {self.session_id} para {self.usuario.nombre}"