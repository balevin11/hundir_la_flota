extends Node

var historial_escenas = []  # Guarda la pila de escenas


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func cambiar_escena(nueva_ruta_escena):
	if get_tree().current_scene:
		historial_escenas.append(get_tree().current_scene.scene_file_path) # Guarda la escena actual
	
	get_tree().change_scene_to_file(nueva_ruta_escena)


func volver():
	if historial_escenas.size() > 0:
		var escena_anterior = historial_escenas.pop_back() # Obtiene la última escena del historial
		
		get_tree().change_scene_to_file(escena_anterior)
