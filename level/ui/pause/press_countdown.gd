class_name PressCountdown
extends Node

signal text_changed
signal pressed

enum TextStyle {left, right, replace}

const COUNTDOWN: AudioStream = preload("res://level/ui/sounds/count.mp3")
const COUNTDOWN_END: AudioStream = preload("res://level/ui/sounds/count_end.mp3")

@onready var button: AnimatedButton = get_parent()
@onready var initial_min_size: float = button.custom_minimum_size.x
@onready var initial_max_size: float = button.custom_maximum_size.x
var audio_player: AudioStreamPlayer

@export var countdown_style: TextStyle = TextStyle.left
@export var countdown_time: int = 5
var count: float = -1.0

func _ready() -> void:
	await get_tree().process_frame
	
	button.button.button_down.connect(button_down)
	button.button.button_up.connect(button_up)
	
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Sounds"
	audio_player.volume_db = -6.5
	add_child(audio_player)

func _physics_process(delta: float) -> void:
	if count < 0.0: return
	
	var last_count: float = count
	count -= delta * 3.0 # made it faster cuz it feels better
	
	if ceili(last_count) != ceili(count) and count > 0:
		audio_player.stream = COUNTDOWN
		audio_player.play()
	
	update_text(count)
	if count <= 0.0:
		count = -1.0
		
		pressed.emit()
		button_up()

		audio_player.stream = COUNTDOWN_END
		audio_player.play()

func update_text(number: float) -> void:
	var last_text: String = button.label.text
	
	var count_text: String = "[" + str(ceili(number)) + "]"
	var reg_text: String = button.label_text
	
	match countdown_style:
		TextStyle.left:
			button.set_text(count_text + " " + reg_text)
		TextStyle.right:
			button.set_text(reg_text + " " + count_text)
		TextStyle.replace:
			button.set_text(count_text)
	
	if button.label.text != last_text:
		text_changed.emit()

func button_down() -> void:
	button.custom_minimum_size.x = button.size.x
	button.custom_maximum_size.x = button.size.x
	
	if Input.is_action_pressed("skip_count"):
		count = 0.01
	else:
		count = float(countdown_time)
		audio_player.stream = COUNTDOWN
		audio_player.play()

func button_up() -> void:
	button.custom_minimum_size.x = initial_min_size
	button.custom_maximum_size.x = initial_max_size
	count = -1.0
	
	button.set_text(button.label_text)
	text_changed.emit()
