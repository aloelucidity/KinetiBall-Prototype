class_name AnimatedButton
extends PanelContainer


@onready var label_outline: Label = $MarginContainer/LabelOutline
@onready var label: Label = $MarginContainer/Label
@onready var button: Button = $NOSCALE_Button

@export_group("Text")
@export var label_text: String

@export_group("Color")
@export var modulate_self: bool = true
@export var color_tint: Color = Color.RED
@export var tint_speed: float = 8

@export_group("Floating")
@export var float_speed: float = 1
@export var float_intensity: float = 1.5
@export var float_offset: float

@export_group("Rotating")
@export var rotate_speed: float = 0.75
@export var rotate_intensity: float = 3
@export var rotate_offset: float

@export_group("Scaling")
@export var scale_speed: float = 6
@export var scale_intensity: float = 1.075

@export_group("Pressing")
@export var click_decay: float = 5
@export var click_intensity: float = 0.1
@export var children_scale_intensity: float = 1.05
@export var click_ease: float = 0.7

var time_offset: float
var hovered: float
var tween: Tween

var base_scale := Vector2.ONE
var override_time: float = 0.0
var initial_position: Vector2

signal pressed

func _init() -> void:
	time_offset = randf() * 1000


func _ready() -> void:
	await get_tree().process_frame
	button.connect("mouse_entered", mouse_entered)
	button.connect("mouse_exited", mouse_exited)
	button.connect("focus_entered", mouse_entered)
	button.connect("focus_exited", mouse_exited)
	button.connect("pressed", button_pressed)
	
	offset_transform_enabled = true
	initial_position = offset_transform_position
	if label_text != "" and is_instance_valid(label):
		set_text(label_text)


func set_text(text: String) -> void:
	label.text = text
	label.visible = (text.length() > 0) ## to fix a clipping issue
	label_outline.text = label.text
	label_outline.visible = label.visible


func mouse_entered():
	hovered = true


func mouse_exited():
	hovered = false


func button_pressed():
	override_time = 1.0
	pressed.emit()


func _process(delta: float) -> void:
	var unix: float = Time.get_unix_time_from_system()
	offset_transform_position = initial_position
	offset_transform_position.y += sin(time_offset + unix * float_speed) * float_intensity
	offset_transform_position.y -= float_offset
	offset_transform_rotation = deg_to_rad(sin(time_offset + unix * rotate_speed) * rotate_intensity)
	offset_transform_rotation += deg_to_rad(rotate_offset)
	
	var modulate_var: String = "self_modulate" if modulate_self else "modulate"
	self[modulate_var] = lerp(
		self[modulate_var],
		color_tint if hovered else Color.WHITE,
		delta * tint_speed
	)
	
	var target_scale: Vector2 = Vector2.ONE
	if hovered:
		target_scale = Vector2(scale_intensity, scale_intensity)
	
	if override_time > 0.0:
		var override_intensity: float = ease(override_time, click_ease) * click_intensity
		var override_scale := base_scale + Vector2(override_intensity, override_intensity)
		offset_transform_scale = override_scale
		override_time -= delta * click_decay
	else:
		base_scale = lerp(
			base_scale,
			target_scale,
			delta * scale_speed
		)
		offset_transform_scale = base_scale
	
	if not is_equal_approx(children_scale_intensity, 1.0):
		for child in get_children():
			if child is Control and not child.name.begins_with("NOSCALE"):
				child.offset_transform_enabled = true
				child.offset_transform_scale = Vector2.ONE + (offset_transform_scale - Vector2.ONE) * children_scale_intensity
