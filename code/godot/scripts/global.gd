extends Node

# Variables globales
var is_draging = false
var partida_id = 4
var raton_ocupado = ""
var cookie = "bc68a3bc-0eba-4edb-954b-5322a6fa04ce"
var dificultad
var tu_empiezas
var x_barcos = [-1,-1,-1,-1,-1]
var y_barcos = [-1,-1,-1,-1,-1]
var dir_barcos = ["vacio","vacio","vacio","vacio","vacio"]
var winner
var mi_nombre


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actualizar_dificultad()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func actualizar_dificultad():
	dificultad = Persistencia.config.get_value("Juego", "dificultad", "F")  # F es valor por defecto (Fácil)
