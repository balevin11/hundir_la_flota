import json
from random import randint
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from flotaapp.models import Partida, Roca, Usuarios, SesionesUsuarios, BarcosPartida

# Tamaño de los barcos
LONGITUD_BARCOS = {
    "patrullero": 2,
    "destructor": 3,
    "submarino": 4,
    "portaaviones": 5,
    "acorazado": 6,
}

# Código de los barcos
CODIGO_BARCOS = {
    "patrullero": 0,
    "destructor": 1,
    "submarino": 2,
    "portaaviones": 4,
    "acorazado": 3,
}

@csrf_exempt
def cargar_partida(request, partida_id):
    if request.method == "GET":
        # inicializar atributos
        i = 0
        registro_posicion = []
        # obtener partida
        try:
            partida = Partida.objects.get(id=partida_id)
        except Partida.DoesNotExist:
            return JsonResponse({"error": "Match not found"}, status=404)
        dificultad = partida.dificultad

        # comprobar que no se hayan creado ya las rocas para esta partida
        registro_rocas = list(Roca.objects.filter(partida=partida).values("X", "Y"))
        if len(registro_rocas) == 0:

            # filtro de numero de rocas por dificultad
            if dificultad == "F":
                num_rocas = 10
            elif dificultad == "N":
                num_rocas = 5
            else:
                num_rocas = 0

            # creamos las rocas necesarias
            while i < num_rocas:
                # genramos la posicion aleatoria
                posicion = [randint(1, 10), randint(1, 10)]
                # comprobar que no esté ya ocupada la posición
                if posicion not in registro_posicion:
                    # crear roca y guardarla en una lista
                    roca = Roca(partida=partida, X=posicion[0], Y=posicion[1])
                    registro_rocas.append({'X': roca.X, 'Y': roca.Y})
                    registro_posicion.append(posicion)
                    roca.save()
                    i = i + 1

        # devolver posiciones almacenadas
        return JsonResponse({"rocas": registro_rocas}, safe=False)

    if request.method == "POST":
        try:
            partida = Partida.objects.get(id=partida_id)
        except Partida.DoesNotExist:
            return JsonResponse({"error": "Game match not found"}, status=404)

        session_id = request.COOKIES.get('SESSION_ID')

        # comprobaciones de SesionesUsuario
        if session_id is None:
            return JsonResponse({"error": "Invalid cookie"}, status=404)
        try:
            session = SesionesUsuarios.objects.get(session_id=session_id)
        except SesionesUsuarios.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=401)

        usuario = session.usuario

        # Controlar que un tercer jugador no autorizado entre en la partida
        if partida.usuario1 != usuario and partida.usuario2 != usuario:
            return JsonResponse({"error": "Unauthorized access"}, status=401)

        # Comprobar que no se hayan posicionado ya los barcos
        if BarcosPartida.objects.filter(partida=partida, jugador=usuario).exists():
            return JsonResponse({"error": "Ships have already been placed in this match."}, status=400)

        # Leer el JSON enviado en el request.body
        cuerpo_respuesta_json = json.loads(request.body)
        if not cuerpo_respuesta_json:
            return JsonResponse({"error": "No ships provided"}, status=400)

        errores = [] # Lista para mostrar uno o varios errores en la respuesta
        tablero_ocupado = set() # Para verificar colisiones con otros barcos
        tablero_ocupado_rocas = set() # Para verificar colisiones con las rocas

        # Obtener lista de rocas de la base de datos
        rocas = Roca.objects.filter(partida=partida_id)

        # Añadir posiciones de rocas a tablero_ocupado_rocas
        for roca in rocas:
            tablero_ocupado_rocas.add((roca.X, roca.Y))

        # Iterar sobre los barcos enviados
        for barco, detalles in cuerpo_respuesta_json.items():
            coordenada_x = detalles.get("x", None)
            coordenada_y = detalles.get("y", None)
            direccion = detalles.get("direccion", None)
            if coordenada_x is None or coordenada_y is None or direccion is None:
                return JsonResponse({"error": "One or more fields are empty"}, status=400)

            # Validar que las posiciones de los barcos sean correctas

            # Validación coordenadas de origen
            if coordenada_x < 1 or coordenada_x > 10:
                errores.append(f"The ship {barco} is wrong positioned in the X axis. X value = {coordenada_x}")

            if coordenada_y < 1 or coordenada_y > 10:
                errores.append(f"The ship {barco} is wrong positioned in the Y axis. Y value = {coordenada_y}")

            # Validación de las demás coordenadas que se propagan debido a la longitud del barco
            longitud = LONGITUD_BARCOS[barco]
            coordenadas_barco = []

            if direccion == "horizontal":
                if coordenada_x + longitud - 1 > 10:
                    errores.append(f"The ship {barco} exceeds horizontal board limits")
                else:
                    # Generar coordenadas del barco
                    for i in range(longitud):
                        coordenadas_barco.append((coordenada_x + i, coordenada_y))

            else: # vertical
                if coordenada_y + longitud - 1 > 10:
                    errores.append(f"The ship {barco} exceeds vertical board limits")
                else:
                    # Generar coordenadas del barco
                    for i in range(longitud):
                        coordenadas_barco.append((coordenada_x, coordenada_y + i))

            # Verificar si alguna coordenada del barco ya está ocupada por otro barco posicionado antes
            colision = False
            for coord in coordenadas_barco:
                if coord in tablero_ocupado:
                    colision = True
                    break

            # Verificar si alguna coordenada del barco coincide con la de alguna roca
            colision_roca = False
            for coord in coordenadas_barco:
                if coord in tablero_ocupado_rocas:
                    colision_roca = True
                    break

            if colision_roca:
                errores.append(f"The ship {barco} collides with a rock")
            elif colision:
                errores.append(f"The ship {barco} collides with another ship")
            else:
                # Agregar las coordenadas al tablero ocupado
                tablero_ocupado.update(coordenadas_barco)

        if errores:
            return JsonResponse({"error": "Invalid ship positions", "errores": errores}, status=400)

        # Si no hay errores, guardar los barcos en la base de datos
        for barco, detalles in cuerpo_respuesta_json.items():
            coordenada_x = detalles["x"]
            coordenada_y = detalles["y"]
            direccion = detalles["direccion"]
            tipo_barco = CODIGO_BARCOS[barco]  # Obtener el índice correspondiente al barco

            BarcosPartida.objects.create(
                partida=partida,
                jugador=usuario,
                X=coordenada_x,
                Y=coordenada_y,
                direccion="H" if direccion == "horizontal" else "V",
                tipo_barco=tipo_barco
            )

        # Mostrar quién tiene el turno inicial para empezar el juego
        turno_jugador = partida.turno_actual

        # Asignar valor booleano a variable tu_empiezas
        if turno_jugador == usuario:
            tu_empiezas = True
        else:
            tu_empiezas = False

        # Todo está correcto
        return JsonResponse({
            "message": "Match created successfully",
            "you_start": tu_empiezas
        }, status=200)

    else:
        return JsonResponse({'error': 'Unsupported HTTP method'},status=405)