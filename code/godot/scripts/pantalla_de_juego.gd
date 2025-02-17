extends Node2D

var partida_id = Global.partida_id
var session_id = Global.cookie
var turno_actual 
var jugador_nombre = Global.mi_nombre
var x_ataque
var y_ataque
var ultimo_ataque = null
@onready var mi_tablero: Node2D = $tablero_propio
@onready var tablero_rival: Node2D = $tablero_rival
@onready var timer: Timer = $Timer
const ANIMACION_EXPLOSION = preload("res://escenas/animacion_explosion.tscn")
const ANIMACION_AGUA = preload("res://escenas/agua_animacion.tscn")
const ANIMACION_HUMO = preload("res://escenas/animacion_humo.tscn")
const CASILLA_ATAQUE = preload("res://escenas/casilla_ataque.tscn")
const DESTRUCTOR = preload("res://escenas/destructor.tscn")
const SUBMARINO = preload("res://escenas/submarino.tscn")
const ACORAZADO = preload("res://escenas/acorazado.tscn")
const PORTAAVIONES = preload("res://escenas/portaaviones.tscn")

func _ready():
	crear_tablero_rival()
	if Global.tu_empiezas:
		turno_actual= Global.mi_nombre
	const PATRULLERO = preload("res://escenas/patrullero.tscn")
	var child_patrullero = PATRULLERO.instantiate()
	add_child(child_patrullero)
	var casilla_patrullero = mi_tablero.get_node("casillas").get_child(int(str(Global.y_barcos[0]-1) + str(Global.x_barcos[0]-1)))
	child_patrullero.global_position = casilla_patrullero.global_position
	child_patrullero.set_script(null)
	child_patrullero.apply_scale(Vector2(1.35, 1.35))
	if Global.dir_barcos[0] == "vertical":
		child_patrullero.rotation_degrees = 90
		
	const DESTRUCTOR = preload("res://escenas/destructor.tscn")
	var child_destructor = DESTRUCTOR.instantiate()
	add_child(child_destructor)
	var casilla_destructor = mi_tablero.get_node("casillas").get_child(int(str(Global.y_barcos[1]-1) + str(Global.x_barcos[1]-1)))
	child_destructor.global_position = casilla_destructor.global_position
	child_destructor.set_script(null)
	child_destructor.apply_scale(Vector2(1.35, 1.35))
	if Global.dir_barcos[1] == "vertical":
		child_destructor.rotation_degrees = 90
		
	const SUBMARINO = preload("res://escenas/submarino.tscn")
	var child_submarino = SUBMARINO.instantiate()
	add_child(child_submarino)
	var casilla_submarino = mi_tablero.get_node("casillas").get_child(int(str(Global.y_barcos[2]-1) + str(Global.x_barcos[2]-1)))
	child_submarino.global_position = casilla_submarino.global_position
	child_submarino.set_script(null)
	child_submarino.apply_scale(Vector2(1.35, 1.35))
	if Global.dir_barcos[2] == "vertical":
		child_submarino.rotation_degrees = 90
		
	const ACORAZADO = preload("res://escenas/acorazado.tscn")
	var child_acorazado = ACORAZADO.instantiate()
	add_child(child_acorazado)
	var casilla_acorazado = mi_tablero.get_node("casillas").get_child(int(str(Global.y_barcos[3]-1) + str(Global.x_barcos[3]-1)))
	child_acorazado.global_position = casilla_acorazado.global_position
	child_acorazado.set_script(null)
	child_acorazado.apply_scale(Vector2(1.35, 1.35))
	if Global.dir_barcos[3] == "vertical":
		child_acorazado.rotation_degrees = 90
		
	const PORTAAVIONES = preload("res://escenas/portaaviones.tscn")
	var child_portaaviones = PORTAAVIONES.instantiate()
	add_child(child_portaaviones)
	var casilla_portaaviones = mi_tablero.get_node("casillas").get_child(int(str(Global.y_barcos[4]-1) + str(Global.x_barcos[4]-1)))
	child_portaaviones.global_position = casilla_portaaviones.global_position
	child_portaaviones.set_script(null)
	child_portaaviones.apply_scale(Vector2(1.35, 1.35))
	if Global.dir_barcos[4] == "vertical":
		child_portaaviones.rotation_degrees = 90
	
func crear_tablero_rival():
	for y in range(10):
		for x in range(10):
			var casilla = CASILLA_ATAQUE.instantiate()
			casilla.position = Vector2(x * 32.2 - 145.5, y * 32.2 -145.5)
			
			# Usar el nuevo método para establecer coordenadas
			casilla.set_coordenadas(x, y)
			
			# Set a unique name for the casilla
			casilla.name = "casilla_%d_%d" % [x, y]
			
			# Añadir al árbol de escena
			tablero_rival.get_node("casillas").add_child(casilla)
			
			# Verificar después de añadir
			print("Verificando casilla %s - coordenadas: (%d, %d)" % [
				casilla.name,
				casilla.get_coord_x(),
				casilla.get_coord_y()
			])
	tablero_rival.ready_rival()

			
func _on_Timer_timeout():
	verificar_estado_partida()

func verificar_estado_partida():
	var url = "http://127.0.0.1:8000/api/1/partida/%s/turno" % str(partida_id)
	
	var headers = ["Cookie: SESSION_ID=" + str(session_id)]
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.connect("request_completed", _on_HTTPRequest_request_completed)
	http_request.request(url,headers)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("Código de respuesta: ", response_code)
	print("Cuerpo de la respuesta: ", body.get_string_from_utf8())
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		if (response["ataque_rival"] != ultimo_ataque):
			turno_actual = response["turno"]
			actualizar_mi_tablero(response["ataque_rival"], response["resultado_ataque_rival"], response["partida_finalizada"], response["ganador"])
			ultimo_ataque=response["ataque_rival"]
			# Verificar si la partida terminó
			if response["partida_finalizada"]:
				mostrar_ganador(response["ganador"])
	else:
		print("Error al obtener estado de la partida", response)

func actualizar_tablero_rival(resultado, partida_finalizada, ganador):
		var casilla = tablero_rival.get_node("casillas/casilla_%d_%d" % [x_ataque-1, y_ataque-1])
		print("Casilla: ", casilla.name)  # Mostrará el nombre de la casilla
		if casilla:  # Comprobamos si el nodo existe antes de intentar modificarlo
			var child = ANIMACION_EXPLOSION.instantiate()
			child.global_position = casilla.global_position
			add_child(child)
			child.play("default")
			match resultado:
				"Agua":
					var child_agua = ANIMACION_AGUA.instantiate()
					child_agua.global_position = casilla.global_position
					add_child(child_agua)
					child_agua.play("default")
					casilla.modulate = Color(0, 0, 1)  # Azul para agua
				"Patrullero", "Destructor", "Submarino", "Acorazado", "Portaaviones":
					var child_humo = ANIMACION_HUMO.instantiate()
					child_humo.global_position = casilla.global_position
					add_child(child_humo)
					child_humo.play("default")
					casilla.modulate = Color(1, 0, 0)  # Rojo para impacto
		if partida_finalizada:
			mostrar_ganador(ganador)
func realizar_ataque(x, y):
	x_ataque=x+1
	y_ataque=y+1
	if turno_actual != jugador_nombre:
		print("No es tu turno aún")
		return
	
	var url = "http://127.0.0.1:8000/api/1/partida/%s/turno" % str(partida_id)
	var headers = ["Content-Type: application/json", "Cookie: SESSION_ID=" + str(session_id)]
	var body = JSON.stringify({"ataque": [x_ataque, y_ataque]})
	print("Enviando solicitud HTTP POST...")
	var http_request2 = HTTPRequest.new()
	add_child(http_request2)
	http_request2.connect("request_completed", _on_HTTPRequest_request_completed_post)
	http_request2.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_HTTPRequest_request_completed_post(result, response_code, headers, body):
	print("Código de respuesta: ", response_code)
	print("Cuerpo de la respuesta: ", body.get_string_from_utf8())
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		turno_actual = response["turno"]
		actualizar_tablero_rival(response["resultado_ataque"], response["partida_finalizada"], response["ganador"])
	else:
		print(response["error"])

func actualizar_mi_tablero(resultado, resultado_ataque, partida_finalizada, ganador):
	if resultado:
		var x = resultado[0]  # Coordenada x del ataque
		var y = resultado[1]  # Coordenada y del ataque
		print(x,y)
		# Aplicamos la fórmula para obtener el número de la casilla
		var casilla = mi_tablero.get_node("casillas").get_child(int(str(y-1) + str(x-1)))
		print("Casilla: ", casilla.name)  # Mostrará el nombre de la casilla
		
		if casilla:  # Comprobamos si el nodo existe antes de intentar modificarlo
			var child = ANIMACION_EXPLOSION.instantiate()
			child.global_position = casilla.global_position
			add_child(child)
			child.play("default")
			match resultado_ataque:
				"Agua":
					var child_agua = ANIMACION_AGUA.instantiate()
					child_agua.global_position = casilla.global_position
					add_child(child_agua)
					child_agua.play("default")
					casilla.modulate = Color(0, 0, 1)  # Azul para agua
				"Patrullero", "Destructor", "Submarino", "Acorazado", "Portaaviones":
					var child_humo = ANIMACION_HUMO.instantiate()
					child_humo.global_position = casilla.global_position
					add_child(child_humo)
					child_humo.play("default")
					casilla.modulate = Color(1, 0, 0)  # Rojo para impacto
					
		if partida_finalizada:
			mostrar_ganador(ganador)

	if partida_finalizada:
		mostrar_ganador(ganador)

func mostrar_ganador(ganador):
	print("¡Partida finalizada! Ganador:", ganador)
	Global.winner=ganador
	get_tree().change_scene_to_file("res://escenas/pantalla_finalizado.tscn")
