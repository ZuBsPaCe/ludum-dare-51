extends Node


const _exhaust_particle_scene := preload("res://Helpers/Particles/ExhaustParticle.tscn")
const _ship_particle_scene := preload("res://Helpers/Particles/ShipParticle.tscn")
const _star_scene := preload("res://Helpers/Stars/Star.tscn")
const _gravity_line_scene := preload("res://Helpers/GravityLine/GravityLine.tscn")
const _bullet_scene := preload("res://Helpers/Bullets/Bullet.tscn")
const _cloud_scene := preload("res://Helpers/Cloud/Cloud.tscn")
const _explosion_scene := preload("res://Scenes/Explosion.tscn")


var _bullet_container: Node2D
var _particle_container: Node2D


var _exhaust_particle_cache := []
var _ship_particle_cache := []

var _star_scene_cache := []


func setup(
		p_bullet_container: Node2D,
		p_particle_container: Node2D):
	_bullet_container = p_bullet_container
	_particle_container = p_particle_container


func create_exhaust_particle(p_pos: Vector2, p_ship_velocity: Vector2, p_ship_rot: float) -> void:
	var particle: Node2D = _exhaust_particle_cache.pop_back()
	
	if particle == null:
		particle = _exhaust_particle_scene.instance()
	
	particle.setup(p_pos, p_ship_velocity, p_ship_rot)
	_particle_container.add_child(particle)
	

func destroy_exhaust_particle(particle: Node2D) -> void:
	_particle_container.remove_child(particle)
	_exhaust_particle_cache.append(particle)


func create_ship_particle(p_pos: Vector2, p_rot: float) -> void:
	var particle: Node2D = _ship_particle_cache.pop_back()
	
	if particle == null:
		particle = _ship_particle_scene.instance()
	
	particle.setup(p_pos, p_rot)
	_particle_container.add_child(particle)
	

func destroy_ship_particle(particle: Node2D) -> void:
	_particle_container.remove_child(particle)
	_ship_particle_cache.append(particle)
	

func create_star(p_container: Node2D, p_frame: int, p_blink: bool, p_step_factor: float, p_speed_factor: float, p_scale: float) -> void:	
	var star: Node2D = _star_scene_cache.pop_back()
	
	if star == null:
		star = _star_scene.instance()
		
	p_container.add_child(star)
	star.setup(p_frame, p_blink, p_step_factor, p_speed_factor, p_scale)
	
	

func destroy_star(particle: Node2D) -> void:
	particle.get_parent().remove_child(particle)
	_star_scene_cache.append(particle)
	
	
func create_gravity_line(var container) -> Node2D:
	var sprite: Node2D = _gravity_line_scene.instance()
	container.add_child(sprite)
	return sprite
	

func destroy_gravity_line(gravity_line: Node2D) -> void:
	gravity_line.queue_free()
	
	
func create_bullet(p_pos: Vector2, p_velocity: Vector2) -> Node2D:
	var bullet = _bullet_scene.instance()
	_bullet_container.add_child(bullet)
	bullet.setup(p_pos, p_velocity)
	return bullet
	

func destroy_bullet(bullet: Node2D) -> void:
	bullet.queue_free()
	

func create_clouds(p_pos: Vector2) -> void:
	for i in range(15):
		var rot: float = Globals.rand_effect.randf() * TAU
		var velocity: Vector2 = Vector2.RIGHT.rotated(Globals.rand_effect.randf() * TAU) * Globals.rand_effect.randf() * 25.0
		
		var pos: Vector2 = p_pos + velocity.normalized() * Globals.rand_effect.randf() * 20.0
		
		var rotation_velocity: float = Globals.rand_effect.randf() * TAU
		var lifetime: float = Globals.rand_effect.randf() * 2.0 + 1.0
		
		var cloud = _cloud_scene.instance()
		_particle_container.add_child(cloud)
		cloud.setup(pos, rot, velocity, rotation_velocity, lifetime)
	

func destroy_cloud(cloud: Node2D) -> void:
	cloud.queue_free()
	
	
func create_explosion(p_pos: Vector2, p_velocity: Vector2) -> Node2D:
	var explosion = _explosion_scene.instance()
	_particle_container.add_child(explosion)
	explosion.setup(p_pos, p_velocity)
	return explosion
	

func destroy_explosion(explosion: Node2D) -> void:
	explosion.queue_free()
	

