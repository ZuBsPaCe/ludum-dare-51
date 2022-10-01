extends Sprite


const _initial_alpha := 0.5
const _base_delay := 0.2
const _on_delay := 3.0
const _off_delay := 0.2

var _blink_timer: Timer


func setup(p_pos: Vector2, p_frame: int, p_blink: bool):
	position = p_pos
	frame = p_frame
	#set_process(false)
	
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


func _blink_timeout():
	if !is_inside_tree():
		return
	
	if modulate.a == 1.0:
		modulate.a = _initial_alpha
		_blink_timer.start(Globals.rand_effect.randf() * _on_delay + _base_delay)
	else:
		modulate.a = 1.0
		_blink_timer.start(Globals.rand_effect.randf() * _off_delay + _base_delay)




