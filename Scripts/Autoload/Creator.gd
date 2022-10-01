extends Node

const ParticleType := preload("res://Scripts/ParticleType.gd")

const _round_particle_scene := preload("res://Helpers/Particles/RoundParticle.tscn")
const _ship_particle_scene := preload("res://Helpers/Particles/ShipParticle.tscn")


var _particle_container: Node2D

var _round_particle_cache := []
var _ship_particle_cache := []


func setup(
		p_particle_container: Node2D):
	_particle_container = p_particle_container


func create_round_particle(p_pos: Vector2) -> void:
	var particle: Node2D = _round_particle_cache.pop_back()
	
	if particle == null:
		particle = _round_particle_scene.instance()
	
	particle.setup(ParticleType.ROUND_PARTICLE, p_pos, 0.0)
	_particle_container.add_child(particle)


func create_ship_particle(p_pos: Vector2, p_rot: float) -> void:
	var particle: Node2D = _ship_particle_cache.pop_back()
	
	if particle == null:
		particle = _ship_particle_scene.instance()
	
	particle.setup(ParticleType.SHIP_PARTICLE, p_pos, p_rot)
	_particle_container.add_child(particle)
	


func destroy_particle(particle_type, particle: Node2D) -> void:
	_particle_container.remove_child(particle)
	
	match particle_type:
		ParticleType.ROUND_PARTICLE:
			_round_particle_cache.append(particle)
			
		ParticleType.SHIP_PARTICLE:
			_ship_particle_cache.append(particle)
		
		_:
			assert(false)
