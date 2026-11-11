class_name PauseController
extends CanvasLayer

@onready var cooldown: Timer = %Cooldown
@onready var screen_manager: ScreenManager = %Screens
@onready var blur_animation: AnimationPlayer = %BlurAnimation

@onready var pause_sound: AudioStreamPlayer = %PauseSound
@onready var unpause_sound: AudioStreamPlayer = %UnpauseSound

# so that you can press pause to go back on this screen
@export var main_screen: Screen

var is_open: bool

func set_tree_paused(value: bool) -> void:
	get_tree().paused = value

func can_pause() -> bool:
	return not Transitions.transitioning

func pause() -> void:
	if not cooldown.is_stopped(): return
	cooldown.start()
	
	if is_open:
		Music.unpause()
		unpause_sound.play()
		
		is_open = false
		screen_manager.current_screen.transition("")
		blur_animation.play("transition")
		
		cooldown.timeout.connect(set_tree_paused.bind(false), CONNECT_ONE_SHOT)
	
	elif can_pause():
		Music.pause()
		pause_sound.play()
		
		is_open = true
		screen_manager.screen_change("MainMenu")
		blur_animation.play_backwards("transition")
		
		set_tree_paused(true)

func _unhandled_input(event: InputEvent) -> void:
	# when it's open, the pause ui itself handles the pause call
	if not screen_manager.transitioning and Globals.can_pause and event.is_action_pressed("pause"):
		if not is_open:
			pause()
		else:
			if screen_manager.current_screen == main_screen:
				(main_screen.get_node("Focus") as UIFocus).back_press.emit()
