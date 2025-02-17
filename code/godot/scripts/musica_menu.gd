extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
var playback_position: float = 0.0  # Guarda la posición para reanudar

func _ready():
	if audio_player:
		if not audio_player.is_playing():
			audio_player.play()
			audio_player.seek(playback_position)  # Reanuda en la posición guardada

func activar_musica():
	if audio_player:
		if not audio_player.is_playing():
			audio_player.play()
			audio_player.seek(playback_position)

func desactivar_musica():
	if audio_player and audio_player.is_playing():
		playback_position = audio_player.get_playback_position()  # Guarda la posición actual
		audio_player.stop()
