class_name LevelScene
extends Node2D


@export var player_spawner: PlayerSpawner
@export var character_camera: CharacterCamera
@export var audio_stream: AudioStream = preload("res://music/bgm.ogg")
@export_range(-80, 24, 0.1, "prefer_slider") var music_volume: float = -4.0


func _ready() -> void:
	if not Music.bgm.playing or Music.bgm.stream != audio_stream:
		Music.bgm.stream = audio_stream
		Music.bgm.volume_db = music_volume
		Music.bgm_start_vol = db_to_linear(music_volume)
		Music.bgm.play()
