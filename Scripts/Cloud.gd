extends Sprite



var _velocity: Vector2
var _rotation_velocity: float
var _lifetime: float
var _total_lifetime: float


func setup(p_pos: Vector2, p_rotation: float, p_velocity: Vector2, p_rotation_velocity: float, p_lifetime: float):
	position = p_pos
	rotation = p_rotation
	_velocity = p_velocity
	_lifetime = p_lifetime
	_total_lifetime = _lifetime


func _process(delta):
	_lifetime -= delta
	
	if _lifetime <= 0.0:
		Creator.destroy_cloud(self)
		return
	
	position += _velocity * delta
	rotation += _rotation_velocity * delta
	
	modulate.a = clamp(_lifetime * 3.0 / _total_lifetime, 0.0, 1.0) * 0.3
		
