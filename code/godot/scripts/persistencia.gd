extends Node

const PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Se ejecuta al inicio del juego
func _ready() -> void:
	load_data() 
	
	# Establecer valores por defecto solo si no existen
	for i in range(3):
		# Si no existe una configuración previa sobre el sonido
		if not config.has_section_key("Audio", str(i)):
			config.set_value("Audio", str(i), 1.0)  # 1.0 evita que el volumen empiece en mute
	
	# Si no existe una configuración previa sobre la dificultad
	if not config.has_section_key("Juego", "dificultad"):
		config.set_value("Juego", "dificultad", 0)  # 0 = Fácil

	save_data()  # Guardar la configuración actualizada
	load_volumes()  # Aplicar los volúmenes al inicio del juego


func load_data():
	if config.load(PATH) != OK:
		save_data()  # Si el archivo no existe, lo crea con valores por defecto


func save_data():
	config.save(PATH)


func load_volumes():
	var master_vol = config.get_value("Audio", "0", 1.0)
	var musica_vol = config.get_value("Audio", "1", 1.0)
	var sfx_vol = config.get_value("Audio", "2", 1.0)
	
	# Establecer los volúmenes guardados previamente por el usuario en configuraciones
	AudioServer.set_bus_volume_db(0, linear_to_db(master_vol))
	AudioServer.set_bus_volume_db(1, linear_to_db(musica_vol))
	AudioServer.set_bus_volume_db(2, linear_to_db(sfx_vol))
