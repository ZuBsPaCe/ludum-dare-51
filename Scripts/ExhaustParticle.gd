extends Node2D

export var _total_lifetime := 1.0
export var _speed := 100.0
export var _offset := 20.0
export var _spread := 10.0

var _lifetime := 0.0
var _velocity := Vector2.ZERO

var _initial_scale: Vector2
var _initial_alpha: float

var _initialized := false

func setup(p_pos: Vector2, p_ship_velocity: Vector2, p_ship_rot: float):
	p_ship_rot += deg2rad(Globals.rand_effect.randf_range(-_spread, _spread))
	
	position = p_pos + Vector2.LEFT.rotated(p_ship_rot) * _offset
	_velocity = p_ship_velocity + Vector2.LEFT.rotated(p_ship_rot) * _speed
	
	_lifetime = 0.0
	
	if _initialized:
		scale = _initial_scale
		modulate.a = _initial_alpha
	else:
		_initial_scale = scale
		_initial_alpha = modulate.a
		_initialized = true
		
	set_process(true)


func _process(delta):
	_lifetime += delta
	
	if _lifetime >= _total_lifetime:
		Creator.destroy_exhaust_particle(self)
		return
	
	var factor := 1.0 - _lifetime / _total_lifetime
	
	scale = factor * _initial_scale
	modulate.a = factor * _initial_alpha
	
	position += _velocity * delta
