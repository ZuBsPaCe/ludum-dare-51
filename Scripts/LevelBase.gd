extends Node2D


const LevelState := preload("res://Scripts/LevelState.gd")


onready var _level_state := $LevelStateMachine
onready var _entity_container := $EntityContainer
onready var _gravity_line := $GravityLine
onready var _camera := $Camera2D

var _ship: KinematicBody2D
var _planets: Array
var _goal: Area2D


var _initial_positions: Dictionary
var _initial_rotations: Dictionary

var _ship_move_speed := 350.0
var _ship_turn_speed := PI

var _ship_velocity := Vector2.ZERO

var _locked_planet: KinematicBody2D
var _locked_distance: float


func _ready():
	for entity in _entity_container.get_children():
		_initial_positions[entity] = entity.position
		_initial_rotations[entity] = entity.rotation
		
		if entity.is_in_group(Globals.GROUP_SHIP):
			_ship = entity
		elif entity.is_in_group(Globals.GROUP_PLANET):
			_planets.append(entity)
	
	for obj in get_children():
		if obj.is_in_group(Globals.GROUP_GOAL):
			_goal = obj
			break
			
	_level_state.setup(
		LevelState.RESET,
		funcref(self, "_on_LevelStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_LevelStateMachine_exit_state"))
	
	_goal.connect("body_entered", self, "_on_goal_body_entered")
			
	set_process(false)


func start_level():
	_level_state.set_state(LevelState.RESET)
	_camera.current = true
	set_process(true)
	

func stop_level():
	_camera.current = false
	set_process(false)


func _process(delta: float):
	var nearest_planet = null
	var nearest_distance = -1.0
	
	for planet in _planets:
		var distance = _ship.position.distance_to(planet.position)
		if nearest_distance < 0.0 || distance < nearest_distance:
			nearest_planet = planet
			nearest_distance = distance
	
	_gravity_line.visible = true
	_gravity_line.position = nearest_planet.position
	_gravity_line.rotation = _ship.position.angle_to_point(_gravity_line.position)
	_gravity_line.scale.x = nearest_distance / 64.0		
	
	match _level_state.current:			
		LevelState.START:
			_ship.rotation = Globals.get_global_mouse_position().angle_to_point(_ship.position)
			
			if Input.is_action_just_pressed("start"):
				_ship_velocity = Vector2.RIGHT.rotated(_ship.rotation) * _ship_move_speed
				_level_state.set_state(LevelState.FLYING)
		
		LevelState.FLYING:
			_ship.rotation = Globals.get_global_mouse_position().angle_to_point(_ship.position)
			
			var booster_force := Vector2.ZERO
			
			if Input.is_action_pressed("booster"):
				booster_force = Vector2.RIGHT.rotated(_ship.rotation) * 500.0
				_ship.booster_enabled = true
			else:
				_ship.booster_enabled = false
			
			var planet_forces := Vector2.ZERO
			
			for planet in _planets:
				var planet_vec: Vector2 = planet.position - _ship.position
				var distance := planet_vec.length()
				
				var force := (1.0 - distance / 500.0)

				if force > 0.0:
					force = force * force
					planet_forces += planet_vec.normalized() * force * 2000.0
			
			_ship_velocity += (booster_force + planet_forces) * delta
			
			var direction = Vector2.RIGHT.rotated(_ship.rotation)
			
			var reset := false
			if _ship.move_and_collide(_ship_velocity * delta):
				reset = true
			elif !Tools.get_visible_rect().has_point(_ship.position):
				reset = true
			
			if reset:
				_level_state.set_state(LevelState.RESET)	
				return
	

func _on_goal_body_entered(body: Node):
	if body.is_in_group(Globals.GROUP_SHIP):
		_level_state.set_state(LevelState.GOAL_REACHED)


func _on_LevelStateMachine_enter_state():
	match _level_state.current:
		LevelState.RESET:			
			for entity in _initial_positions.keys():
				entity.position = _initial_positions[entity]
			
			for entity in _initial_rotations.keys():
				entity.rotation = _initial_rotations[entity]
			
			_gravity_line.visible = false
			_ship.booster_enabled = false
			
			_level_state.set_state_after_frame(LevelState.START)
		
		LevelState.START:
			_ship.collision_enabled = true
			
		LevelState.GOAL_REACHED:
			_ship.collision_enabled = false
			_ship.booster_enabled = false
			
			State.goal_reached()


func _on_LevelStateMachine_exit_state():
	match _level_state.current:
		LevelState.START:
			pass
