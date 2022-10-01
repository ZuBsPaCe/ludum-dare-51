extends Node

var _enity_container
var _ship_scene := preload("res://Scenes/Ship.tscn")


var _ship


func setup(
		p_entity_container):
	_enity_container = p_entity_container


func create_ship(pos: Vector2) -> KinematicBody2D:
	assert(_ship == null)
	_ship = _ship_scene.instance()
	_ship.setup(pos)
	_enity_container.add_child(_ship)
	return _ship


func destroy_ship() -> void:
	_enity_container.remove_child(_ship)
	_ship = null
