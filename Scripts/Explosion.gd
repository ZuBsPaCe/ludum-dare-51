extends Node2D


var _velocity: Vector2
onready var _particles := $Particles


func setup(p_pos: Vector2, p_velocity: Vector2):
	position = p_pos
	_velocity = p_velocity
	
	_particles.emitting = true


func _process(delta):
	position += delta * _velocity
	
	if !_particles.emitting:
		Creator.destroy_explosion(self)
	
	
	
