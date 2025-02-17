extends Node2D

const MUSICA_MENU = preload("res://escenas/musica_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicaMenu.activar_musica()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
