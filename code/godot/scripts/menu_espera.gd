extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var url = "http://127.0.0.1:8000/api/1/matchmaking"
	var headers = [
		"Content-Type: application/json",
		"Cookie: SESSION_ID=" + Global.cookie, 
	]
	var http_request = HTTPRequest.new()
	var body = JSON.stringify({"dificultad": Global.dificultad})
	
	add_child(http_request) # Necesario para que el HTTPRequest funcione
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	http_request.connect("request_completed", _on_post_request_completed) #(señal que se emite al finalizar, nombre de función) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_post_request_completed(result, response_code, headers, body):
	if response_code == 200:
		poll()
	else:
		print("Error: HTTP code received: ", response_code)


# Función para consultar repetidamente
func poll():
	var url = "http://127.0.0.1:8000/api/1/matchmaking"
	var headers = [
		"Content-Type: application/json",
		"Cookie: SESSION_ID=" + Global.cookie,
	]
	var http_request = HTTPRequest.new()
	
	add_child(http_request)
	http_request.request(url, headers, HTTPClient.METHOD_GET)
	http_request.connect("request_completed", _on_get_request_completed, CONNECT_ONE_SHOT) # CONNECT_ONE_SHOT hace que la conexión se desconecte despues de ejecutarse una vez (para que no se acumulen múltiples conexiones y generar llamadas duplicadas)


func _on_get_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		var json = JSON.parse_string(response_text)
		
		if json.has("partida_id") and json["partida_id"] != null:
			Global.partida_id = json["partida_id"]
			ManagerEscenas.cambiar_escena("res://escenas/posicionar_barcos.tscn")
		else:
			# todavía no se encontró partida
			await get_tree().create_timer(3.0).timeout
			poll()
	else:
		print("Error in GET request. Code: ", response_code)


func _on_boton_volver_pressed() -> void:
	ManagerEscenas.volver()


#ManagerEscenas en teoría está inicializado en otra parte. Debería de funcionar.
