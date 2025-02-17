import json
# comprobado: creacion de matchmaking, que se junten y cree partida que no se pueda crear matchmaking con partida creada ni matchmaking creado
from django.db.models import Q, F
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from flotaapp.models import Emparejamiento, Usuarios, Partida, SesionesUsuarios


@csrf_exempt
def matchmaking(request):
    if request.method == "POST":
        # inicializar variables
        partida_vacio = False
        # cargar cuerpo
        cuerpo = json.loads(request.body)
        dificultad = cuerpo.get("dificultad")
        cancel_matchmaking = cuerpo.get("cancel_matchmaking")
        # obtener el id del usuario a partir de las cookies
        session_id = request.COOKIES.get('SESSION_ID')

        # comprobaciones de SesionesUsuario
        if session_id is None:
            return JsonResponse({"error": "Invalid cookie"}, status=404)
        try:
            session = SesionesUsuarios.objects.get(session_id=session_id)
        except SesionesUsuarios.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=401)

        usuario = session.usuario

        juegos_usuario = usuario.partidas_jugadas

        # comprobar que la dificultad sea válida
        if dificultad not in ["F", "N", "D", None]:
            return JsonResponse({"error": "Invalid difficulty"}, status=400)

        # comprobar que no tenga un emparejamiento ni una partida activos
        try:
            partida = Partida.objects.get((Q(usuario1=usuario) | Q(usuario2=usuario)) & Q(partida_terminada=False))
        except Partida.DoesNotExist:
            partida_vacio = True
        if not partida_vacio:
            return JsonResponse({"error": "You have a pending match", "partida_id": partida.id}, status=409)
        try:
            emparejamiento = Emparejamiento.objects.get(usuario1=usuario, usuario2=None)
        except Emparejamiento.DoesNotExist:
            if partida_vacio:
                # si hay cancel_matchmaking y no hay sala para eliminar
                if cancel_matchmaking:
                    return JsonResponse({"message": "Matchmaking is clean"})

                # obtener una sala libre dentro de la dificultad
                sala_disponible = (Emparejamiento.objects
                                   .annotate(
                    partidas_jugadas_u1=F('usuario1__partidas_jugadas'))  # Acceder a partidas_jugadas de usuario1
                                   .filter(partidas_jugadas_u1__gte=juegos_usuario - 10,
                                           partidas_jugadas_u1__lte=juegos_usuario + 10, dificultad=dificultad,
                                           usuario2=None).first())

                # si no existen una sala libre crear una
                if sala_disponible is None:
                    Emparejamiento(usuario1=usuario, dificultad=dificultad).save()
                else:
                    # añadir al usuario a la sala
                    sala_disponible.usuario2 = usuario
                    sala_disponible.save()
                    partida = Partida(usuario1=sala_disponible.usuario1, usuario2=sala_disponible.usuario2,
                                      dificultad=sala_disponible.dificultad)
                    partida.save()

                return JsonResponse({"message": "User in matchmaking queue"})

        # en caso de cancelar la partida se recibira una cancel_matchmaking true para eliminar la sala
        if cancel_matchmaking:
            emparejamiento.delete()
            return JsonResponse({"message": "Matchmaking canceled"})
        return JsonResponse({"error": "You are already in a matchmaking room"}, status=409)


    elif request.method == "GET":
        # cargar usuario de las cookies
        session_id = request.COOKIES.get('SESSION_ID')

        # comprobaciones de SesionesUsuario
        if session_id is None:
            return JsonResponse({"error": "Invalid cookie"}, status=404)
        try:
            session = SesionesUsuarios.objects.get(session_id=session_id)
        except SesionesUsuarios.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=401)

        usuario = session.usuario

        # obtener la partida
        # Q es para poder realizar condiciones and y or si no son todas and
        try:
            partida = Partida.objects.get(Q(partida_terminada=False) & (Q(usuario1=usuario) | Q(usuario2=usuario)))

        # si no existe avisar
        except Partida.DoesNotExist:
            return JsonResponse({"status": "Match not found"})

        # si hay varias partidas activas error, eliminar alguna
        except Partida.MultipleObjectsReturned:
            return JsonResponse({"error": "Multiple matches active"}, status=400)

        # comprobar si el turno ya es de alguien, si no es de nadie asignar al
        # otro jugador para evitar iniciar la partida sin que esten los dos jugadores
        if partida.turno_actual != partida.usuario2 and partida.turno_actual != partida.usuario1:
            if usuario == partida.usuario2:
                partida.turno_actual = partida.usuario1
            else:
                partida.turno_actual = partida.usuario2
            partida.save()
        return JsonResponse({"status": "Match found", "partida_id": partida.id})
    else:
        return JsonResponse({'error': 'Unsupported HTTP method'}, status=405)
