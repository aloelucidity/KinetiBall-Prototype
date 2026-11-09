class_name Screen
extends Control


signal start_transition
signal screen_opened
signal screen_change(new_screen_name: String)

@export var music_id: int = -1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var transitioning: bool


func _ready() -> void:
	# it's often preset to make previews easier,
	# but the theme should be set by the menu controller
	# to make custom themes quick and easy to code
	theme = null


func transition(new_screen_name: String) -> void:
	if is_instance_valid(get_viewport().gui_get_focus_owner()): 
		get_viewport().gui_get_focus_owner().release_focus()
	
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	
	start_transition.emit()
	
	transitioning = true
	animation_player.play("transition")
	animation_player.animation_finished.connect(animation_finished.bind(new_screen_name), CONNECT_ONE_SHOT)


func animation_finished(_anim_name: StringName, new_screen_name: String) -> void:
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
	
	screen_change.emit(new_screen_name)
	transitioning = false
