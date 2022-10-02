extends KinematicBody2D


var _rotation_speed: float

const max_diameter := 64.0
var _diameter := 0.0

func _ready():	
	var min_pos := Vector2.ZERO
	var max_pos := Vector2.ZERO
	
	for pos in get_node("CollisionPolygon2D").polygon:
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	_diameter = min_pos.distance_to(max_pos)
	
	Globals.rand_asteroid.seed = get_index()
	_rotation_speed = max(1.0 - (_diameter / max_diameter), 0.05) * Globals.rand_asteroid.randf_range(-0.75, 0.75) * TAU

	
func _process(delta):
	rotation += _rotation_speed * delta
	
