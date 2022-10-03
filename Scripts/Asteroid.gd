extends KinematicBody2D


var _rotation_speed: float

const max_diameter := 64.0
var _diameter := 0.0

var _total_health: int
var _health: int

var _collision_polygon: CollisionPolygon2D

func _ready():	
	var min_pos := Vector2.ZERO
	var max_pos := Vector2.ZERO
	
	_collision_polygon = get_node("CollisionPolygon2D")
	for pos in _collision_polygon.polygon:
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	_diameter = min_pos.distance_to(max_pos)
	
	Globals.rand_asteroid.seed = get_index()
	_rotation_speed = max(1.0 - (_diameter / max_diameter), 0.05) * Globals.rand_asteroid.randf_range(-0.75, 0.75) * TAU

	_total_health = 1
	_health = _total_health


func set_collision_enabled(enabled: bool):
	_collision_polygon.disabled = !enabled


func hurt():
	if _health <= 0:
		return
	
	_health -= 1
	
	if _health > 0:
		return
		
	Creator.create_clouds(position)
	Creator.create_explosion(position, Vector2.ZERO)
	Effects.shake(Vector2.RIGHT.rotated(Globals.rand_effect.randf() * TAU))
	
	if Globals.sound:
		Globals.sound.play(Globals.SOUND_ASTEROID_DESTROYED, position)
	
	visible = false
	_collision_polygon.disabled = true


func reset_health():
	_health = _total_health
	visible = true
	_collision_polygon.disabled = false

	
func _process(delta):
	rotation += _rotation_speed * delta
	
