extends KinematicBody2D


var _velocity: Vector2
var _disabled := false

var _lifetime := 2.0


func setup(p_pos: Vector2, p_velocity: Vector2):
	position = p_pos
	_velocity = p_velocity
	
	rotation = _velocity.angle()
	_disabled = false
	_lifetime = 2.0
	

func disable_collision():
	_disabled = true
	
	
func _process(delta):
	var collision := move_and_collide(_velocity * delta)
	if collision:
		if Globals.sound:
			Globals.sound.play(Globals.SOUND_BULLET_HIT, position)
		
		if !_disabled and collision.collider.is_in_group(Globals.GROUP_ASTEROID):
			collision.collider.hurt()
			
		Creator.destroy_bullet(self)
		return
	
	_lifetime -= delta
	if _lifetime <= 0.0:
		Creator.destroy_bullet(self)
