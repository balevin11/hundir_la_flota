extends Node

var error_sound 
var casillas_patrullero = []
var casillas_destructor = []
var casillas_submarino = []
var casillas_portaaviones = []
var casillas_acorazado = []
var error_label
var timer
var succesful_sound

func _ready() -> void:
	#inicializar nodos
	error_label = $"../label/error"
	timer = $"../Timer"
	error_sound = $"../sonidos/error sound"
	succesful_sound =$"../sonidos/succesfull_sound"
	#eliminar el focus de los botones
	$"../botones/ajustes".focus_mode = Button.FOCUS_NONE
	$"../botones/confirmar".focus_mode = Button.FOCUS_NONE
	$"../botones/deshacer".focus_mode = Button.FOCUS_NONE

func permiso_de_posicionar(posicion :int , horizontal :bool):
	#X e Y inicial para el proceso del servidor
	var Xi = posicion % 10
	var Yi = posicion / 10
	#X e Y para godot
	var X = (posicion-1) % 10
	var Y = (posicion-1) / 10
	
	var casilla
	var casillas = []
	var tamano
	var barco = Global.raton_ocupado
	
	#vover a activar casillas 
	reactivar_casillas(barco)
	#vaciar casillas del barco
	grabar_casilla(barco,casillas)
	#si se posiciona fuera del tablero
	if posicion == -1:
		return false
	#ontener el tamaño del barco
	if barco == "patrullero":
		tamano = 2
	elif barco =="destructor":
		tamano = 3
	elif barco =="submarino":
		tamano = 4
	elif barco =="portaaviones":
		tamano = 5
	elif barco =="acorazado":
		tamano = 6
	else :
		return false
		
	#recorrer las casillas ocupadas por el barco
	for i in range(tamano):
		var Xc = X
		var Yc = Y
		#control de direccion en la que avanzar para comprobar casillas
		if horizontal:
			Xc = X + i
		else:
			Yc = Y + i
			
		#si se sale por los lados
		if horizontal and Xc == 9 and i != tamano-1:
			return false
		elif not horizontal and Yc == 9 and i != tamano-1:
			return false
		
		#obtener el nodo casilla 
		casilla = %tablero_posicionar_barcos/casillas.get_child(int(str(Yc) + str(Xc)))
		#comprobar que la casilla no esté desactivada
		if casilla.get_node("deshabilitado").disabled:
			return false
		casillas.append(casilla)
		
	#guardar las casillas ocupadas
	grabar_casilla(barco, casillas)
	#desactivar las casillas ocupadas
	desactivar_casillas(barco)
	#guardar la posicion inicial
	guardar_posicion(barco,Xi,Yi,horizontal)
	return true

func guardar_posicion(barco :String, x, y, horizontal):
	var posicion
	var direccion 
	#control horizontal vertical
	if horizontal:
		direccion = "horizontal"
	else:
		direccion ="vertical"
	
	#control de ubicacion en el array segun el barco
	if barco == "patrullero":
		posicion = 0
	elif barco == "destructor":
		posicion = 1
	elif barco == "submarino":
		posicion = 2
	elif barco == "portaaviones":
		posicion = 3
	elif barco == "acorazado":
		posicion = 4
	
	#grabar en los array
	Global.x_barcos[posicion] = x
	Global.y_barcos[posicion] = y+1
	Global.dir_barcos[posicion] = direccion

func grabar_casilla(barco :String, casillas):
	#grabar las casillas en el array que toque
	if barco == "patrullero":
		casillas_patrullero = casillas
	elif barco =="destructor":
		casillas_destructor = casillas
	elif barco =="submarino":
		casillas_submarino = casillas
	elif barco =="portaaviones":
		casillas_portaaviones = casillas
	elif barco =="acorazado":
		casillas_acorazado = casillas

func reactivar_casillas(barco :String):
	if barco == "patrullero":
		for casilla in casillas_patrullero:
			casilla.get_node("deshabilitado").disabled = false #activar casilla
	elif barco =="destructor":
		for casilla in casillas_destructor:
			casilla.get_node("deshabilitado").disabled = false
	elif barco =="submarino":
		for casilla in casillas_submarino:
			casilla.get_node("deshabilitado").disabled = false
	elif barco =="portaaviones":
		for casilla in casillas_portaaviones:
			casilla.get_node("deshabilitado").disabled = false
	elif barco =="acorazado":
		for casilla in casillas_acorazado:
			casilla.get_node("deshabilitado").disabled = false
		
func desactivar_casillas(barco :String):
	if barco == "patrullero":
		for casilla in casillas_patrullero:
			casilla.get_node("deshabilitado").disabled = true #desactivar casilla
	elif barco =="destructor":
		for casilla in casillas_destructor:
			casilla.get_node("deshabilitado").disabled = true
	elif barco =="submarino":
		for casilla in casillas_submarino:
			casilla.get_node("deshabilitado").disabled = true
	elif barco =="portaaviones":
		for casilla in casillas_portaaviones:
			casilla.get_node("deshabilitado").disabled = true
	elif barco =="acorazado":
		for casilla in casillas_acorazado:
			casilla.get_node("deshabilitado").disabled = true
		
func reactivar_todas_casillas():
	for casilla in casillas_patrullero:
		casilla.get_node("deshabilitado").disabled = false
	for casilla in casillas_destructor:
		casilla.get_node("deshabilitado").disabled = false
	for casilla in casillas_submarino:
		casilla.get_node("deshabilitado").disabled = false
	for casilla in casillas_portaaviones:
		casilla.get_node("deshabilitado").disabled = false
	for casilla in casillas_acorazado:
		casilla.get_node("deshabilitado").disabled = false
		
func _on_deshacer_pressed() -> void:
	#desactivar todas las casillas ocupadas, mandar los barcos a a su sitio y vaciar casillar de los barcos
	reactivar_todas_casillas()
	casillas_patrullero = []
	casillas_destructor = []
	casillas_submarino = []
	casillas_portaaviones = []
	casillas_acorazado = []
	$"../barcos/portaaviones".volver_al_sitio()
	$"../barcos/destructor".volver_al_sitio()
	$"../barcos/acorazado".volver_al_sitio()
	$"../barcos/submarino".volver_al_sitio()
	$"../barcos/patrullero".volver_al_sitio()

func _on_confirmar_pressed() -> void:
	#comprobar barcos posicionados
	if len(casillas_patrullero) == 2 and len(casillas_destructor) == 3 and len(casillas_submarino) == 4 and len(casillas_portaaviones) == 5 and len(casillas_acorazado) == 6:
		hacer_post()
	else:
		error_label.text = "Place all the ships"
		error_sound.play() #activar sonido
		error_label.visible = true #hacer label visible
		timer.start() #activar temporizador

func _on_timer_timeout() -> void:
	error_label.visible = false #hacer label invisible
	
func hacer_post():
	#hacer el POST
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_server_has_responded)
	#cuerpo del POST
	var body = JSON.stringify({"patrullero":{"x":Global.x_barcos[0],"y":Global.y_barcos[0], "direccion":Global.dir_barcos[0]}, 
								"destructor":{"x":Global.x_barcos[1],"y":Global.y_barcos[1], "direccion":Global.dir_barcos[1]}, 
								"submarino":{"x":Global.x_barcos[2],"y":Global.y_barcos[2], "direccion":Global.dir_barcos[2]}, 
								"portaaviones":{"x":Global.x_barcos[3],"y":Global.y_barcos[3], "direccion":Global.dir_barcos[3]}, 
								"acorazado":{"x":Global.x_barcos[4],"y":Global.y_barcos[4], "direccion":Global.dir_barcos[4]}})
	#cabeceras del POST
	var headers = ["Content-Type: application/json", "Cookie: SESSION_ID=" +str(Global.cookie)]
	http_request.request("http://127.0.0.1:8000/api/1/partida/" +str(Global.partida_id), headers,HTTPClient.METHOD_POST, body)
	
func _on_server_has_responded(result, response_code, headers, body):
	var response =  JSON.parse_string(body.get_string_from_utf8())

	#si respuesta correcta
	if response_code == 200:
		#obtener mensaje de respuesta
		var message = response.get("message", "")
		if message == "Match created successfully":
			#obtener si empiezas y grabarlo en la variable global
			var you_start = response.get("you_start", false)
			Global.tu_empiezas = you_start 
			succesful_sound.play()#activar sonido
			#cambiar de escena a esperar a jugar
			ManagerEscenas.cambiar_escena("res://escenas/pantalla_de_juego.tscn")

	else:
		#obtener mensaje de error
		var error = str(response.get("error", ""))
		error_sound.play()#activar sonido
		error_label.text = error#cambiar label de error
		error_label.visible = true#hacer label visible
		timer.start()#empezar temporizador
	
