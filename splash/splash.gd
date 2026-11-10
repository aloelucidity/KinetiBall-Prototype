extends Control


@onready var wild_jam: Control = $WildJam
@onready var luci: Control = $Luci
@onready var kinetiball: Control = $KinetiBall

@onready var wild_player: AnimationPlayer = wild_jam.get_node("AnimationPlayer")
@onready var luci_player: AnimationPlayer = luci.get_node("AnimationPlayer")
@onready var kinetiplayer: AnimationPlayer = kinetiball.get_node("AnimationPlayer")

func _ready() -> void:
	await get_tree().process_frame
	
	#wild_jam.show()
	#wild_player.play("splash")
	#
	#await wild_player.animation_finished
	#wild_jam.hide()
	
	luci.show()
	luci_player.play("splash")
	Music.intro_jingle.play()
	await luci_player.animation_finished
	#luci.hide()
	
	#kinetiball.show()
	#kinetiplayer.play("splash")
	#await kinetiplayer.animation_finished
	
	Globals.is_splash = false
	Transitions.change_scene("res://level/level_scenes/tutorial.tscn", null, 0)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return
	if event.is_action_pressed("ui_cancel"):
		if luci_player.is_playing():
			luci_player.speed_scale = INF
			Music.fade_jingle()
