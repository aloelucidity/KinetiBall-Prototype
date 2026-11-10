class_name RainbowGlow
extends TextureRect


@export var saturation: float
@export var rainbow_speed: float


func _process(_delta: float) -> void:
	self_modulate.h = wrapf(Time.get_unix_time_from_system() * rainbow_speed, 0.0, 1.0)
	self_modulate.s = saturation
