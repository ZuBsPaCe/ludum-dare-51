extends Sprite


const _initial_alpha := 0.5
const _base_delay := 0.2
const _on_delay := 3.0
const _off_delay := 0.2

var _blink_timer: Timer

var _step_factor: float
var _spawn_factor: float
var _speed_factor: float

func setup(p_frame: int, p_blink: bool, p_step_factor: float, p_speed_factor: float, p_scale: float):
	frame = p_frame
	_step_factor = p_step_factor
	_spawn_factor = Globals.rand_effect.randf()
	_speed_factor = p_speed_factor
	
	scale = Vector2(p_scale, p_scale)
	
	modulate.a = _initial_alpha
	
	if p_blink:
		if _blink_timer == null:
			_blink_timer = Timer.new()
			_blink_timer.one_shot = true
			_blink_timer.autostart = false
			_blink_timer.connect("timeout", self, "_blink_timeout")
			add_child(_blink_timer)
		
		_blink_timer.start(Globals.rand_effect.randf() * _on_delay + _base_delay)
	else:
		if _blink_timer != null:
			_blink_timer.queue_free()
	
	_update_pos()
	

func _update_pos():
	var pos := Vector2.ZERO

	if Globals.star_anim_3d_factor > 0.0:
		pos = _get_pos_3d()
	elif Globals.star_anim_right_left_factor > 0.0:
		pos = Globals.star_anim_right_left_factor * _get_pos_right_left()
		
	elif Globals.star_anim_top_down_factor > 0.0:
		pos = Globals.star_anim_top_down_factor * _get_pos_top_down()
	
	position = pos


	
func _get_pos_top_down() -> Vector2:
	var start := Globals.canvas_rect.position
	var end := Globals.canvas_rect.end
	start.x += _spawn_factor * Globals.canvas_rect.size.x
	end.x = start.x
	
	return lerp(start, end, _step_factor)


func _get_pos_right_left() -> Vector2:
	var start := Globals.canvas_rect.end
	var end := Globals.canvas_rect.position
	start.y -= _spawn_factor * Globals.canvas_rect.size.y
	end.y = start.y
	
	return lerp(start, end, _step_factor)
	


func _get_pos_3d() -> Vector2:
	var factor_3d := Globals.star_anim_3d_factor
	
	var start1 := Globals.canvas_rect.end
	var end1 := Globals.canvas_rect.position
	start1.y -= _spawn_factor * Globals.canvas_rect.size.y
	end1.y = start1.y
	
	
	var center_3d : Vector2 = lerp(Vector2(4000.0, -100), Globals.STAR_ANIM_SOURCE, factor_3d)
	
	
	var start2 : Vector2 = lerp(start1, center_3d, factor_3d)
	
	var rot_factor = (_spawn_factor - 0.5) * 1.8 * PI
	var end2 := (end1 - start2).rotated(rot_factor)
	
	var start = lerp(start1, start2, factor_3d)
	var end = lerp(end1, end2, factor_3d)
	
	return lerp(start, end, lerp(_step_factor, _step_factor * _step_factor * _step_factor, factor_3d))
	
	
	
func _get_pos_3d_old(shift_factor: float) -> Vector2:
	var start := Vector2(300.0, -100) + shift_factor * Vector2(Globals.canvas_rect.size.x - 300, 0)
	var end: Vector2
	if _spawn_factor < 0.25:
		end = Globals.canvas_rect.position
		end.x += _spawn_factor * 4.0 * Globals.canvas_rect.size.x
	elif _spawn_factor < 0.5:
		end = Globals.canvas_rect.end
		end.x -= (_spawn_factor - 0.25) * 4.0 * Globals.canvas_rect.size.x
	elif _spawn_factor < 0.75:
		end = Globals.canvas_rect.position
		end.y += (_spawn_factor - 0.5) * 4.0 * Globals.canvas_rect.size.y
	else:
		end = Globals.canvas_rect.end
		end.y -= (_spawn_factor - 0.75) * 4.0 * Globals.canvas_rect.size.y
	
	return lerp(start, end, _step_factor)# * _step_factor * _step_factor)
	

			
func _process(delta):
	if Globals.star_anim_speed == 0.0:
		return
		
	_step_factor += Globals.star_anim_speed * 4.0 * _speed_factor * delta
	if _step_factor >= 1.0:
		_step_factor -= 1.0
		
	_update_pos()


func _blink_timeout():
	if !is_inside_tree():
		return
	
	if modulate.a == 1.0:
		modulate.a = _initial_alpha
		_blink_timer.start(Globals.rand_effect.randf() * _on_delay + _base_delay)
	else:
		modulate.a = 1.0
		_blink_timer.start(Globals.rand_effect.randf() * _off_delay + _base_delay)




