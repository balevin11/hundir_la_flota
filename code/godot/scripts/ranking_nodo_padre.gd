extends Node2D

@onready var titulos_nombre : RichTextLabel = $labels/titulos_nombre
@onready var titulos_partidas : RichTextLabel = $labels/titulos_partidas
@onready var titulos_victorias : RichTextLabel = $labels/titulos_victorias
@onready var titulos_porcentaje : RichTextLabel = $labels/titulos_porcentaje
@onready var campeon_nombre : RichTextLabel = $labels/campeon_nombre
@onready var campeon_partidas : RichTextLabel = $labels/campeon_partidas
@onready var campeon_victorias : RichTextLabel = $labels/campeon_victorias
@onready var campeon_porcentaje : RichTextLabel = $labels/campeon_porcentaje
@onready var segundo_nombre : RichTextLabel = $labels/segundo_nombre
@onready var segundo_partidas : RichTextLabel = $labels/segundo_partidas
@onready var segundo_victorias : RichTextLabel = $labels/segundo_victorias
@onready var segundo_porcentaje : RichTextLabel = $labels/segundo_porcentaje
@onready var tercero_nombre : RichTextLabel = $labels/tercero_nombre
@onready var tercero_partidas : RichTextLabel = $labels/tercero_partidas
@onready var tercero_victorias : RichTextLabel = $labels/tercero_victorias
@onready var tercero_porcentaje : RichTextLabel = $labels/tercero_porcentaje
@onready var cuarto_nombre : RichTextLabel = $labels/cuarto_nombre
@onready var cuarto_partidas : RichTextLabel = $labels/cuarto_partidas
@onready var cuarto_victorias : RichTextLabel = $labels/cuarto_victorias
@onready var cuarto_porcentaje : RichTextLabel = $labels/cuarto_porcentaje
@onready var quinto_nombre : RichTextLabel = $labels/quinto_nombre
@onready var quinto_partidas : RichTextLabel = $labels/quinto_partidas
@onready var quinto_victorias : RichTextLabel = $labels/quinto_victorias
@onready var quinto_porcentaje : RichTextLabel = $labels/quinto_porcentaje
@onready var error : Label = $labels/error
@onready var error_sonido :AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var cargando :AnimatedSprite2D = $cargando
@onready var vacio :Label = $labels/empty

func _ready():
	cargando.visible = true
	
	# Conectar la señal request_completed
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_http_request_request_completed)
	
	# Realizar la solicitud GET
	http_request.request("http://127.0.0.1:8000/api/1/ranking")

func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == 200:  # Si la respuesta fue exitosa
		var response =  JSON.parse_string(body.get_string_from_utf8())
		var posicion = 1
		print(response)
		if response ==[]:
			cargando.visible = false
			vacio.visible = true
		#visualizar rankers
		for ranker in response:
			if response_code == 200:
				var espacios_usuario = ""
				var espacios_jugadas = ""
				var espacios_ganadas = ""
				var usuario = ranker["usuario"]
				var partidas_ganadas = ranker["victorias"]
				var partidas_jugadas = ranker["partidas"]
				var porcentaje = round((float(partidas_ganadas) / float(partidas_jugadas)) * 10000)/100 
				
				#generador de espacios
				for i in range(23-len(usuario)):
					espacios_usuario += " "
				for i in range(15-len(str(partidas_ganadas))):
					espacios_ganadas += " "
				for i in range(14-len(str(partidas_jugadas))):
					espacios_jugadas += " "
					
				#filtrar los tres primero
				if posicion == 1:
					cargando.visible = false
					titulos_nombre.visible = true
					titulos_partidas.visible = true
					titulos_victorias.visible = true
					titulos_porcentaje.visible = true
					campeon_nombre.text = "[wave amp=50 freq=2][color=#eee709]" + usuario + "[/color][/wave]"
					campeon_partidas.text ="[wave amp=50 freq=2][color=#eee709]" + str(partidas_jugadas) + "[/color][/wave]" 
					campeon_victorias.text = "[wave amp=50 freq=2][color=#eee709]" + str(partidas_ganadas) + "[/color][/wave]" 
					campeon_porcentaje.text = "[wave amp=50 freq=2][color=#eee709]" + str(porcentaje) + "%[/color][/wave]"
					$copas/copa_1.visible = true
				elif posicion == 2:
					segundo_nombre.text = "[color=#d3d0d0]" + usuario + "[/color]"
					segundo_partidas.text ="[color=#d3d0d0]" + str(partidas_jugadas) + "[/color]" 
					segundo_victorias.text = "[color=#d3d0d0]" + str(partidas_ganadas) + "[/color]" 
					segundo_porcentaje.text = "[color=#d3d0d0]" + str(porcentaje) + "%[/color]"
					$copas/copa_2.visible = true
				elif posicion == 3:
					tercero_nombre.text = "[color=#cd7f32]" + usuario + "[/color]"
					tercero_partidas.text ="[color=#cd7f32]" + str(partidas_jugadas) + "[/color]" 
					tercero_victorias.text = "[color=#cd7f32]" + str(partidas_ganadas) + "[/color]" 
					tercero_porcentaje.text = "[color=#cd7f32]" + str(porcentaje) + "%[/color]"
					$copas/copa_3.visible = true
				elif posicion == 4:
					cuarto_nombre.text = "[color=#ffffff]" + usuario + "[/color]"
					cuarto_partidas.text ="[color=#ffffff]" + str(partidas_jugadas) + "[/color]" 
					cuarto_victorias.text = "[color=#ffffff]" + str(partidas_ganadas) + "[/color]" 
					cuarto_porcentaje.text = "[color=#ffffff]" + str(porcentaje) + "%[/color]"
				else:
					quinto_nombre.text = "[color=#ffffff]" + usuario + "[/color]"
					quinto_partidas.text ="[color=#ffffff]" + str(partidas_jugadas) + "[/color]" 
					quinto_victorias.text = "[color=#ffffff]" + str(partidas_ganadas) + "[/color]" 
					quinto_porcentaje.text = "[color=#ffffff]" + str(porcentaje) + "%[/color]"
				posicion +=1
			else:
				error.text = "Error parsing the response"
				error.visible = true
				error_sonido.play()
	else:
		error.text = "Error in the request"
		error.visible = true
		error_sonido.play()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")
