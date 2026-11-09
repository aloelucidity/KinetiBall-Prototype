class_name UIFocus
extends Control


signal back_press

@export var disabled: bool
@export var default_focus: Button


func _ready() -> void:
	if owner is Screen:
		var screen: Screen = owner
		screen.screen_opened.connect(focus_node)


func _input(event: InputEvent) -> void:
	if disabled: return
	if not is_visible_in_tree(): return
	
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if focus_owner is LineEdit or focus_owner is TextEdit: return
	if focus_owner != null and event is InputEventMouseMotion and !Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT): 
		focus_owner.release_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return

	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if event.is_action_pressed("ui_cancel"):
		if not (focus_owner is LineEdit or focus_owner is TextEdit):
			if not owner is Screen or not (owner as Screen).transitioning: 
				back_press.emit()
	
	if disabled: return
	if not is_instance_valid(default_focus): return
	
	if not is_instance_valid(focus_owner):
		if (event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		or event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")):
			# we don't want the cursor to move immediately after grabbing focus
			await get_tree().process_frame
			if default_focus.get_focus_mode_with_override() == FocusMode.FOCUS_ALL:
				default_focus.grab_focus()


func set_default_focus(node_path: String) -> void:
	default_focus = get_node_or_null(NodePath(node_path)) as Button


func focus_node(node_path: String = "") -> void:
	if LastInputDevice.is_mouse: return
	
	var node: Control = default_focus
	if node_path != "":
		node = get_node(NodePath(node_path)) as Control
	
	if is_instance_valid(node):
		node.grab_focus()
