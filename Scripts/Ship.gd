extends KinematicBody2D


onready var _collision := $CollisionPolygon2D


var collision_enabled: bool setget _set_collision_enabled, _get_collision_enabled


func setup(p_pos: Vector2):
	position = p_pos
	

func _set_collision_enabled(value):
	_collision.disabled = !value


func _get_collision_enabled():
	return !_collision.disabled
