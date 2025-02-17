extends Node2D
#comentarios en el patrullero, codigo csi igual
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if draggable and (Global.raton_ocupado == "" or Global.raton_ocupado == "acorazado"):
		if Input.is_action_just_pressed("click_izquierdo"):
			Global.is_draging = true
			Global.raton_ocupado = "acorazado"
		if Input.is_action_pressed("click_izquierdo"):
				global_position = get_global_mouse_position()
				if Input.is_action_just_pressed("click_derecho"):
					if rotation_degrees == 90:
						rotation_degrees = 0 
						horizontal = true
					else:
						rotation_degrees = 90
						horizontal = false
				
		if Input.is_action_just_released("click_izquierdo"):
			Global.is_draging = false
			
			tween = get_tree().create_tween()
			
			if is_inside_droppable:
				#posicion casilla ubicacion
				posicion = int(body_ref.name.substr(7, body_ref.name.length()))
				#en la posicion 100 nunca ser podrá posicionar
				if posicion != 100:
					
					#pedir permiso para posicionar, mandar numero de la casilla y orientacion
					permiso = manager.permiso_de_posicionar(posicion, horizontal)
				else:
					permiso = false
				if permiso:
					tween.tween_property(self,"position", body_ref.position,0.2).set_ease(Tween.EASE_OUT)
					drop_sound.play()
				else:
					volver_al_sitio()
			else:
				manager.permiso_de_posicionar(-1, false)
				volver_al_sitio()
				
			Global.raton_ocupado = ""
			
func _on_area_clicable_mouse_entered() -> void:
	if not Global.is_draging:
		draggable = true
		scale = Vector2(1.05,1.05)
		
func _on_area_clicable_mouse_exited() -> void:
	if not Global.is_draging:
		draggable = false
		scale = Vector2(1,1)

func _on_area_2d_body_exited(body: StaticBody2D) -> void:
	if body.is_in_group('droppables'):
		is_inside_droppable = false


func _on_area_2d_body_entered(body: StaticBody2D) -> void:
	if body.is_in_group('droppables'):
		is_inside_droppable = true
		body_ref = body

func volver_al_sitio():
	tween = get_tree().create_tween()
	tween.tween_property(self,"global_position", initialPos,0.2).set_ease(Tween.EASE_OUT)
	rotation_degrees = 0
	horizontal = true
