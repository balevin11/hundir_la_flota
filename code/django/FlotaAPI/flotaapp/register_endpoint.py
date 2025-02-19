import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from flotaapp.models import Usuarios
from django.contrib.auth.hashers import make_password

@csrf_exempt
def register(request):
    if request.method != 'POST':
        #Comprobamos que el metodo sea un POST
        return JsonResponse({'error': 'Unsupported HTTP method'}, status=405)

    body = json.loads(request.body)
    new_username = body.get('username', None)

    if new_username is None:
        #Error si falta el nombre de usuario
        return JsonResponse({'error': 'Missing username in request body'}, status=400)

    try:
        Usuarios.objects.get(nombre=new_username)
    except Usuarios.DoesNotExist:
        # Si el usuario no existe
        new_password = body.get('contrasena', None)

        if new_password is None:
            #Error si falta la contraseña
            return JsonResponse({'error': 'Missing password in request body'}, status=400)

        hashed_password=make_password(new_password) # Función de paquete Django para hash

        # Guardar nuevo usuario y contraseña
        new_user = Usuarios()
        new_user.nombre = new_username
        new_user.contrasena = hashed_password
        new_user.save()

        #Mensaje de usuario creado correctamente
        return JsonResponse({'message': 'User created'}, status=201)

    # Si el usuario existe
    return JsonResponse({'error': 'User with given username already exists'}, status=409)


