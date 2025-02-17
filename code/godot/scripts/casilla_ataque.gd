extends Area2D

@export var coordenada_x: int = 0
@export var coordenada_y: int = 0

func _ready():
	assert(has_node("CollisionShape2D"), "La casilla debe tener un CollisionShape2D")
	set_process_input(true)
func set_coordenadas(x: int, y: int):
	coordenada_x = x
	coordenada_y = y
	print("Coordenadas establecidas: ", coordenada_x, ", ", coordenada_y)

func get_coord_x() -> int:
	return coordenada_x

func get_coord_y() -> int:
	return coordenada_y

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Casilla clickeada: (%d, %d) - Nodo: %s" % [coordenada_x, coordenada_y, name])

		var pantalla = get_tree().get_root().find_child("pantalla_de_juego", true, false)
		if pantalla:
			pantalla.realizar_ataque(coordenada_x, coordenada_y)
