extends Node2D

var manager
var drop_sound
var tween :Tween
var X
var Y
var posicion
var horizontal = true
var permiso = false
var draggable = false
var is_inside_droppable = false
var body_ref 
var initialPos: Vector2
func _ready() -> void:
	initialPos = global_position
	tween = get_tree().create_tween()
	drop_sound = $AudioStreamPlayer2D
	manager = %Pocicionar_barcos_manager

func _process(delta: float) -> void:
	#control raton libre o ocupado por este barco y que el objeto sea movible
	if draggable and (Global.raton_ocupado == "" or Global.raton_ocupado == "patrullero"):
		#primer click activa que se esta moviendo el objeto y ocupa el raton
		if Input.is_action_just_pressed("click_izquierdo"):
			Global.is_draging = true
			Global.raton_ocupado = "patrullero"
		
		#mientras se mantiene pulsado la posicion del barco es la del raton
		if Input.is_action_pressed("click_izquierdo"):
				global_position = get_global_mouse_position()
				#si se hace click derecho se girará el barco y actualizará si esta horizontal o verical
				if Input.is_action_just_pressed("click_derecho"):
					if rotation_degrees == 90:
						rotation_degrees = 0 
						horizontal = true
					else:
						rotation_degrees = 90
						horizontal = false
				
		#cuando se suelta el click izquierdo deja de estar arrastrandose
		if Input.is_action_just_released("click_izquierdo"):
			Global.is_draging = false
			tween = get_tree().create_tween()
			#se comprueba que este cobre una casilla
			if is_inside_droppable:
				#obtener posicion casilla 
				posicion = int(body_ref.name.substr(7, body_ref.name.length()))
				#en la posicion 100 nunca ser podrá posicionar
				if posicion != 100:
					#pedir permiso para posicionar, mandar numero de la casilla y orientacion
					permiso = manager.permiso_de_posicionar(posicion, horizontal)
				else:
					permiso = false
					
				#si hay permiso posicionar el barco en el lugar que toque
				if permiso:
					tween.tween_property(self,"position", body_ref.position,0.2).set_ease(Tween.EASE_OUT)
					drop_sound.play()#activar sonido
				else:
					#si no hay permiso volver al sitio inicial
					volver_al_sitio()
			else:
				#si no es una casilla o no esta bien posicionado, informar y volver al sitio
				manager.permiso_de_posicionar(-1, false)
				volver_al_sitio()
			#vaciar raton
			Global.raton_ocupado = ""
			
func _on_area_clicable_mouse_entered() -> void:
	#si el raton entra en el area clicable sin que se este arrastrando, se podra arrastrar este barco
	if not Global.is_draging:
		draggable = true
		scale = Vector2(1.05,1.05)
		
func _on_area_clicable_mouse_exited() -> void:
	#cuando sale el raton sin estar arrastrandose ya no se puede mover el barco
	if not Global.is_draging:
		draggable = false
		scale = Vector2(1,1)

func _on_area_2d_body_exited(body: StaticBody2D) -> void:
	#si el area de posicion sale de una casilla no se podra posicionar el barco
	if body.is_in_group('droppables'):
		is_inside_droppable = false

func _on_area_2d_body_entered(body: StaticBody2D) -> void:
	#si el area de posicion entra en una casilla se podra posicionar el barco
	if body.is_in_group('droppables'):
		is_inside_droppable = true
		body_ref = body

func volver_al_sitio():
	#vuelve al sitio inicial y se vuelve a poner horizontal
	tween = get_tree().create_tween()
	tween.tween_property(self,"global_position", initialPos,0.2).set_ease(Tween.EASE_OUT)
	rotation_degrees = 0
	horizontal = true
