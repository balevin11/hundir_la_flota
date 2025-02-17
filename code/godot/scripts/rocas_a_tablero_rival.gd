extends Node2D

var rocas_array =[]
const roca_scene = preload("res://escenas/roca.tscn")
# Called when the node enters the scene tree for the first time.
func ready_rival() -> void:
	#hacer un GET
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_server_has_responded)
	http_request.request("http://127.0.0.1:8000/api/1/partida/" +str(Global.partida_id))

	
func _on_server_has_responded(result, response_code, headers, body):
	var posicion 
	#transformar body json a string
	var response =  JSON.parse_string(body.get_string_from_utf8())
	if response != null:
		#por cada roca en la respuesta crear nuevo hijo
		for roca in response["rocas"]:
			var child = roca_scene.instantiate()
			#control por posicionamiento en la ultima fila
			if roca["X"] == 10:
				#obtener id de la casilla de la roca(no voy a explicar la formula, mucho lio)
				posicion = int(str(int(roca["Y"])-1) + "0")-1
			else:
				#obtener id de la casilla de la roca
				posicion = int(str(int(roca["Y"])-1) + str(roca["X"]))-1
				
			#obtener casilla por la id
			var casilla = $casillas.get_child(posicion)
			#si existe una casilla desactivarla y posicionar roca
			if casilla:
				child.position = casilla.position
				casilla.get_node("CollisionShape2D").disabled = true#desactivar el colisionshape de la casilla
				add_child(child)
				rocas_array.append(child)
			else:
				print("Casilla no encontrada en la posición:", posicion)
	
