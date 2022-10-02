extends KinematicBody2D


onready var _collision := $CollisionPolygon2D


var collision_enabled: bool setget _set_collision_enabled, _get_collision_enabled
var booster_enabled := false


const _init_trail_countdown := 0.01
var _trail_countdown := _init_trail_countdown

var _last_position := Vector2.ZERO


func _process(delta):
	rotation = Globals.get_global_mouse_position().angle_to_point(position)
	
	var ship_velocity := position - _last_position
	var ship_velocity_dir := ship_velocity.normalized()
	
	if ship_velocity.length_squared() > 0.0:
		_trail_countdown -= delta
		if _trail_countdown <= 0.0:
			_trail_countdown = _init_trail_countdown			
			#Creator.create_ship_particle(position, rotation)
		
	if booster_enabled:
		Creator.create_exhaust_particle(position, ship_velocity, rotation)
	
	_last_position = position
	

func _set_collision_enabled(value):
	_collision.disabled = !value


func _get_collision_enabled():
	return !_collision.disabled
