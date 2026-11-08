@tool
extends CollisionPolygon2D


signal polygon_changed


func _set(property: StringName, _value) -> bool:
	if not Engine.is_editor_hint(): return false
	if property == "polygon":
		polygon_changed.emit()
	return false
