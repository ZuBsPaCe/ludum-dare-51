extends Node2D

export var _total_lifetime := 1.0

var _lifetime := 0.0
var _initial_alpha: float

var _initialized := false

func setup(p_pos: Vector2, p_rot: float):
	position = p_pos
	rotation = p_rot
	
	_lifetime = 0.0
	
	if _initialized:
		modulate.a = _initial_alpha
	else:
		_initial_alpha = modulate.a
		_initialized = true
		
	set_process(true)


func _process(delta):
	_lifetime += delta
	
	if _lifetime >= _total_lifetime:
		Creator.destroy_ship_particle(self)
		return
	
	var factor := 1.0 - _lifetime / _total_lifetime
	
	modulate.a = factor * _initial_alpha
