extends KinematicBody2D


onready var _collision := $CollisionPolygon2D
onready var _window := $Window
onready var _booster_sound := $BoosterSound



var collision_enabled: bool setget _set_collision_enabled, _get_collision_enabled
var booster_enabled := false


const _init_trail_countdown := 0.01
var _trail_countdown := _init_trail_countdown

var _last_position := Vector2.ZERO

var _window_offset := 0.0
var _target_window_offset := 0.0
var _window_speed := 4.0 * 3.0



func _ready():
	pass


func _process(delta):
	var last_rotation := rotation

	rotation = Globals.get_global_mouse_position().angle_to_point(position)
	
	var rotation_speed: float = (rotation - last_rotation) / delta
	if rotation_speed > 0.0 and rotation_speed > PI * 0.25:
		_target_window_offset = 4.0 * clamp(rotation_speed / (PI * 0.25), 0.0, 1.0)
	elif rotation_speed < 0.0 and rotation_speed < -PI * 0.25:
		_target_window_offset = 4.0 * clamp(rotation_speed / (PI * 0.25), -1.0, 0.0)
	else:
		_target_window_offset = 0.0
	
	if _window_offset < _target_window_offset:
		_window_offset = min(_window_offset + _window_speed * delta, _target_window_offset)
	elif _window_offset > _target_window_offset:
		_window_offset = max(_window_offset - _window_speed * delta, _target_window_offset)
		
	_window.position.y = _window_offset
	
	var ship_velocity := position - _last_position
	var ship_velocity_dir := ship_velocity.normalized()
	
	if ship_velocity.length_squared() > 0.0:
		_trail_countdown -= delta
		if _trail_countdown <= 0.0:
			_trail_countdown = _init_trail_countdown			
			#Creator.create_ship_particle(position, rotation)
	
			
	if booster_enabled:
		if !_booster_sound.playing:
			_booster_sound.play()
		#_booster_sound.volume_db = _max_booster_sound_db
		Creator.create_exhaust_particle(position, ship_velocity, rotation)
	else:
		if _booster_sound.playing:
			_booster_sound.stop()
	
	_last_position = position


func start_shoot_sound():
	Globals.sound.play(Globals.SOUND_SHOOT, position)


func _set_collision_enabled(value):
	_collision.disabled = !value


func _get_collision_enabled():
	return !_collision.disabled
