from django.db.models import F, ExpressionWrapper, FloatField
from django.http import JsonResponse
from flotaapp.models import Usuarios

def ranking (request):
    #control que sea un GET
    if request.method == "GET":
        #inicializar variables
        json_usuarios = [] # Lista de JSON
        #crear lista del top 5 por porcentaje de victorias
        #gte es mayor o igual a x
        #annotate permite crear un nuevo atributo en la tabla de forma local
        #ExpressionWrapper es para poder realizar una operacion de atributos dentro de annotate
        #output_field=FloatField() es para marcar que el atributo es un float
        rankers = list(Usuarios.objects.filter(partidas_jugadas__gte=5)
                              .annotate(porcentaje_victorias=ExpressionWrapper(F('partidas_ganadas') / F('partidas_jugadas'), output_field=FloatField()))
                              .order_by("-porcentaje_victorias")[:5].values())

        #grabar top 5 en un json
        for usuario in rankers:
            json_usuarios.append({"usuario": usuario.get("nombre"), "partidas": usuario.get("partidas_jugadas"),"victorias": usuario.get("partidas_ganadas")})
        return JsonResponse(json_usuarios, safe=False)
    else:
        return JsonResponse({'error': 'Unsupported HTTP method'}, status=405)