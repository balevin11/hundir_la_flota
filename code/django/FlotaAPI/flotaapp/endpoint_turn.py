import json

from django.http import JsonResponse, cookie
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from django.core.exceptions import ValidationError
from .models import Partida, Usuarios, Ataques, Roca, BarcosPartida, SesionesUsuarios


@csrf_exempt
def turno(request, partida_id):
    if request.method == "POST":
        try:
            # Obtener la partida, si no lanza automáticamente un error 404
            partida = get_object_or_404(Partida, id=partida_id)
            session_id = request.COOKIES.get('SESSION_ID')

            # comprobaciones de SesionesUsuario
            if session_id is None:
                return JsonResponse({"error": "Invalid cookie"}, status=404)

            try:
                session = SesionesUsuarios.objects.get(session_id=session_id)
            except SesionesUsuarios.DoesNotExist:
                return JsonResponse({"error": "User not found"}, status=401)

            usuario_atacante = session.usuario # Objeto usuario

            # Determinar el usuario defensor (contrincante) basado en el atacante actual
            if usuario_atacante == partida.usuario1:
                usuario_defensor = partida.usuario2
            else:
                usuario_defensor = partida.usuario1

            # Validar que el usuario tiene el turno actual
            if partida.turno_actual.id != usuario_atacante.id:
                return JsonResponse({"error": "It's not your turn"}, status=403)

            # Validar que la partida no ha terminado
            if partida.partida_terminada:
                return JsonResponse({"error": "The game is over"}, status=409)

            # Leer el JSON enviado
            cliente_json = json.loads(request.body)
            posicion_ataque = cliente_json.get("ataque", None)
            if posicion_ataque is None or len(posicion_ataque) != 2:
                return JsonResponse({"error": "Invalid attack coordinates"}, status=400)

            # Desestructuración o unpacking
            x, y = posicion_ataque

            # Validar límites del mapa (Tablero de 10x10)
            if not (1 <= x <= 10 and 1 <= y <= 10):
                return JsonResponse({"message": "Attack coordinates out of range"}, status=400)

            # Validar que no se ha atacado esta posición antes
            if Ataques.objects.filter(partida=partida, X=x, Y=y, atacante=usuario_atacante).exists():
                return JsonResponse({"error": "These coordinates have already been attacked"}, status=400)

            # Validar que no golpee una roca
            if Roca.objects.filter(partida=partida, X=x, Y=y).exists():
                return JsonResponse({"message": "There is a rock in the attack coordinates"}, status=400)

            impacto = False # Variable para controlar si hubo un impacto o no, y mandar una respuesta en consonancia
            resultado_impacto = Ataques.Resultados.AGUA # Código 5
            barco_hundido = False
            barco_impactado = None

            # Determinar las posiciones ocupadas por cada barco
            barcos = BarcosPartida.objects.filter(partida=partida, jugador=usuario_defensor)
            for barco in barcos:
                posiciones_barco = []  # Lista para almacenar las posiciones del barco

                origen_x = barco.X
                origen_y = barco.Y
                longitud = barco.longitud() # Descubrir el tamaño del barco

                # Calcular las posiciones ocupadas según la dirección y longitud del barco
                if barco.direccion == "H": # Horizontal
                    for i in range(longitud):
                        posiciones_barco.append((origen_x + i, origen_y))
                else: # Vertical
                    for i in range(longitud):
                        posiciones_barco.append((origen_x, origen_y + i))

                # Verificar si el ataque coincide con alguna posición del barco
                if (x, y) in posiciones_barco:
                    impacto = True
                    resultado_impacto = barco.tipo_barco
                    barco_impactado = barco

                    # Separar coordenadas para recuento de "vida" del barco
                    coordenadas_x = []
                    coordenadas_y = []

                    for pos in posiciones_barco:
                        coordenadas_x.append(pos[0]) # Guardar todas las coordenadas x en la misma variable
                        coordenadas_y.append(pos[1]) # Guardar todas las coordenadas y en la misma variable

                    # Recuento de impactos en el barco
                    ataques_previos = Ataques.objects.filter(
                        partida=partida,
                        objetivo=usuario_defensor,
                        X__in=coordenadas_x,
                        Y__in=coordenadas_y
                    ).count()

                    # El barco se hunde si este ataque más los previos cubren toda la longitud del barco
                    if ataques_previos + 1 == longitud:
                        barco_hundido = True
                        barco_impactado.hundido = True
                        barco_impactado.save()
                    break

            # Guardar ataque en bbdd
            # Crear una instancia de Ataques
            nuevo_ataque = Ataques(
                partida=partida,
                atacante=usuario_atacante,
                objetivo=usuario_defensor,
                X=x,
                Y=y,
                resultado=resultado_impacto
            )
            # Guardar la instancia en la base de datos
            nuevo_ataque.save()

            # Convertir resultado numérico a string
            nombres_barcos = {
                0: "Patrullero",
                1: "Destructor",
                2: "Submarino",
                3: "Acorazado",
                4: "Portaaviones",
                5: "Agua"
            }
            resultado_string = nombres_barcos[resultado_impacto]

            partida_terminada = False
            ganador = None

            # Verificar si se termina o no la partida
            if barco_hundido:
                barcos_restantes = BarcosPartida.objects.filter(partida=partida, jugador=usuario_defensor, hundido=False)
                if not barcos_restantes.exists():
                    partida_terminada = True
                    ganador = usuario_atacante.nombre

                    # Terminar partida
                    partida.partida_terminada = True
                    partida.ganador = usuario_atacante
                    partida.save()

                    # Actualizar estadísticas
                    usuario_atacante.partidas_ganadas += 1
                    usuario_atacante.partidas_jugadas += 1
                    usuario_atacante.save()
                    usuario_defensor.partidas_jugadas += 1
                    usuario_defensor.save()

            # Si no hubo impacto, cambiar el turno
            if not impacto:
                partida.turno_actual = usuario_defensor
                partida.save()

            return JsonResponse({
                "resultado_ataque": resultado_string,
                "turno": partida.turno_actual.nombre,
                "partida_finalizada": partida_terminada,
                "ganador": ganador
            }, status=200)

        except ValidationError as e:
            return JsonResponse({"error": str(e)}, status=400)
        except Exception as e:
            return JsonResponse({"error": "An unexpected error occurred", "detail": str(e)}, status=500)

    elif request.method == "GET":

        # Validar el session_id directamente desde el modelo
        session_id = request.COOKIES.get('SESSION_ID')

        # comprobaciones de SesionesUsuario
        if session_id is None:
            return JsonResponse({"error": "Invalid cookie"}, status=404)

        try:
            session = SesionesUsuarios.objects.get(session_id=session_id)
        except SesionesUsuarios.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=401)

        usuario = session.usuario # Objeto del usuario

        # Verificar que el usuario esté en la partida
        try:
            partida = Partida.objects.get(id=partida_id)
        except Partida.DoesNotExist:
            return JsonResponse({"error": "Match not found"}, status=404)

        if usuario not in [partida.usuario1, partida.usuario2]:
            return JsonResponse({"error": "User does not belong to this item"}, status=403)

        # Obtener información relevante de la partida
        # Recuperar el último ataque del rival basado en el modelo 'Ataques'
        ultimo_ataque = (
            Ataques.objects.filter(partida=partida, objetivo=usuario)
            .order_by('-id')
            .first()
        )

        ataque_rival = [ultimo_ataque.X, ultimo_ataque.Y] if ultimo_ataque else None
        resultado_ultimo_ataque = (
            Ataques.Resultados(ultimo_ataque.resultado).label if ultimo_ataque else None
        )

        # Otros datos de la partida
        turno_actual = partida.turno_actual.nombre if partida.turno_actual else None # Si no hay turno actual en Partida, es None
        partida_finalizada = partida.partida_terminada
        ganador = partida.ganador.nombre if partida.ganador else None # Si no hay ganador en Partida, es None

        # Respuesta JSON con los datos solicitados
        return JsonResponse({
            "ataque_rival": ataque_rival,
            "resultado_ataque_rival": resultado_ultimo_ataque,
            "turno": turno_actual,
            "partida_finalizada": partida_finalizada,
            "ganador": ganador
        })

    else:
        return JsonResponse({"error": "HTTP method not supported"}, status=405)