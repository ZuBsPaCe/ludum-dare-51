extends Node2D

export var _total_lifetime := 1.0
export var _scale_down := false

var _particle_type
var _lifetime := 0.0
var _initial_scale: Vector2
var _initial_alpha: float

var _initialized := false

func setup(p_particle_type, p_pos: Vector2, p_rot: float):
	_particle_type = p_particle_type
	position = p_pos
	rotation = p_rot
	
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
		Creator.destroy_particle(_particle_type, self)
		return
	
	var factor := 1.0 - _lifetime / _total_lifetime
	
	if _scale_down:
		scale = factor * _initial_scale
	
	modulate.a = factor * _initial_alpha
