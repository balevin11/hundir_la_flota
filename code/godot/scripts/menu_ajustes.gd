extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Master.value = Persistencia.config.get_value("Audio", '0')
	AudioServer.set_bus_volume_db(0, linear_to_db(%Master.value))
	
	%Musica.value = Persistencia.config.get_value("Audio", '1')
	AudioServer.set_bus_volume_db(1, linear_to_db(%Musica.value))
	
	%SFX.value = Persistencia.config.get_value("Audio", '2')
	AudioServer.set_bus_volume_db(2, linear_to_db(%SFX.value))
	
	# Cargar la dificultad guardada
	var dificultad_guardada = Persistencia.config.get_value("Juego", "dificultad", 0) # Asigna valor 0 (Fácil) si no encuentra un valor guardado
	%OptionsButtonDificultad.selected = dificultad_guardada

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_master_value_changed(value: float) -> void:
	set_volume(0, value)


func _on_musica_value_changed(value: float) -> void:
	set_volume(1, value)


func _on_sfx_value_changed(value: float) -> void:
	set_volume(2, value)


func set_volume(idx, value):
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	Persistencia.config.set_value("Audio", str(idx), value)
	Persistencia.save_data()


func _on_options_button_dificultad_item_selected(index: int) -> void:
	# Guardar la nueva selección
	Persistencia.config.set_value("Juego", "dificultad", index)
	Persistencia.save_data()
	
	# Definir el mapeo de índices a letras
	var dificultad_map = ["F", "N", "D"]  # "F" = Fácil, "N" = Media, "D" = Difícil

	# Actualizar la dificultad en la variable global con la letra correspondiente
	Global.dificultad = dificultad_map[index]


func _on_boton_volver_pressed() -> void:
	ManagerEscenas.volver()
