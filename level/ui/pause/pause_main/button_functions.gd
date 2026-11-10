extends Node

@onready var pause_controller: PauseController = owner.owner

func resume() -> void:
	pause_controller.pause()

func quit() -> void:
	get_tree().quit()
