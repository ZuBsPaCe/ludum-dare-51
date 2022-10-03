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

var _last_global_mouse_pos: Vector2

const deadzone = 0.25

func _ready():
	_last_global_mouse_pos = Globals.get_global_mouse_position()


func _process(delta):
	var last_rotation := rotation
	
	var joy_hor := 0.0
	var joy_ver := 0.0
	var joy_pressed := false

	var current_global_mouse_pos := Globals.get_global_mouse_position()
	
	var mouse_moved := _last_global_mouse_pos != current_global_mouse_pos
			
	if mouse_moved and Globals.using_joypad:
		# Attention: Screen shaking leads to a mouse movement...
		var mouse_moved_distance := _last_global_mouse_pos.distance_to(current_global_mouse_pos)
	
		if  mouse_moved_distance > 20.0:
			Globals.using_joypad = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Controller support was added post compo
	if Globals.using_post_compo_version:
		if Globals.using_joypad or not mouse_moved:		
			joy_hor = Input.get_joy_axis(0, 0)
			joy_ver = Input.get_joy_axis(0, 1)
			
			joy_pressed = abs(joy_hor) + abs(joy_ver) > deadzone
			
			if joy_pressed and !Globals.using_joypad:
				Globals.using_joypad = true
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	if !Globals.using_joypad:
		rotation = current_global_mouse_pos.angle_to_point(position)
	elif joy_pressed:
		var offset := joy_hor * Vector2.RIGHT + joy_ver * Vector2.DOWN
		var target := position + offset
		rotation = target.angle_to_point(position)
	
	_last_global_mouse_pos = current_global_mouse_pos
	
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
	#var ship_velocity_dir := ship_velocity.normalized()
	
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
	if Globals.sound:
		Globals.sound.play(Globals.SOUND_SHOOT, position)


func _set_collision_enabled(value):
	_collision.disabled = !value


func _get_collision_enabled():
	return !_collision.disabled
