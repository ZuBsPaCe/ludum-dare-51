extends Node


const _exhaust_particle_scene := preload("res://Helpers/Particles/ExhaustParticle.tscn")
const _ship_particle_scene := preload("res://Helpers/Particles/ShipParticle.tscn")
const _star_scene := preload("res://Helpers/Stars/Star.tscn")
const _gravity_line_scene := preload("res://Helpers/GravityLine/GravityLine.tscn")


var _particle_container: Node2D


var _exhaust_particle_cache := []
var _ship_particle_cache := []

var _star_scene_cache := []


func setup(
		p_particle_container: Node2D):
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
	
