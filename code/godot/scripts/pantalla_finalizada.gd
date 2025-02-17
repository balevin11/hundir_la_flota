extends Node2D

@onready var label: Label = $Label

func _ready():
	var ganador = Global.winner
	label.text = ganador
