class_name ScreenManager
extends Control

signal screen_changed

@export var default_screen: Screen
@onready var current_screen: Screen
var transitioning: bool

func _ready() -> void:
	if is_instance_valid(default_screen):
		current_screen = default_screen
	## TODO: Uncomment once Music singleton is added
	# if is_instance_valid(current_screen) and current_screen.music_id > -1:
	#	Singleton.Music.change_song(Singleton.Music.last_song, current_screen.music_id)
	
	for screen: Screen in get_children():
		screen.connect("screen_change", screen_change)
		screen.visible = (screen == current_screen)
		if screen.visible:
			# a change i made in GD4, RESET animation is now visible instead of
			# hidden, so that editing menus is easier 
			screen.animation_player.play("RESET")
			screen.emit_signal("screen_opened")

func screen_change(new_screen_name: String) -> void:
	if is_instance_valid(current_screen):
		current_screen.hide.call_deferred()
	
	var new_screen: Screen = get_node_or_null(new_screen_name) as Screen
	if not is_instance_valid(new_screen): 
		current_screen = null
		set_transitioning("", false)
		emit_signal("screen_changed")
		return
	
	current_screen = new_screen
	
	new_screen.animation_player.play_backwards("transition")
	# stops the screen from showing for a split second when transitioning
	new_screen.animation_player.advance(0.001)
	new_screen.show.call_deferred()
	
	## TODO: Uncomment once Music singleton is added
	#if new_screen.music_id > -1:
	#	Singleton.Music.change_song(Singleton.Music.last_song, new_screen.music_id)
	
	new_screen.emit_signal("screen_opened")
	emit_signal("screen_changed")
	
	new_screen.animation_player.animation_finished.connect(set_transitioning.bind(false), CONNECT_ONE_SHOT)
	new_screen.start_transition.connect(set_transitioning.bind("", true), CONNECT_ONE_SHOT)

func get_screen_name() -> String:
	if not is_instance_valid(current_screen): return "None"
	return current_screen.name

# animation is just there because animation_finished always returns a value...
func set_transitioning(_animation: String, new_value: bool) -> void:
	transitioning = new_value
