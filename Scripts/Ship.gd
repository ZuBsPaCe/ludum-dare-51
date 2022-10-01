extends KinematicBody2D


const _trail_offset := 5.0


onready var _collision := $CollisionPolygon2D


var collision_enabled: bool setget _set_collision_enabled, _get_collision_enabled

const _init_trail_countdown := 0.01
var _trail_countdown := _init_trail_countdown

var _last_position := Vector2.ZERO


func _process(delta):
	if _last_position != position:
		_trail_countdown -= delta
		if _trail_countdown <= 0.0:
			_trail_countdown = _init_trail_countdown			
			Creator.create_ship_particle(position + (_last_position - position).normalized() * _trail_offset, rotation)
		
		_last_position = position
	

func _set_collision_enabled(value):
	_collision.disabled = !value


func _get_collision_enabled():
	return !_collision.disabled
