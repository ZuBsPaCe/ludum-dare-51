extends Node2D


const LevelState := preload("res://Scripts/LevelState.gd")


onready var _level_state := $LevelStateMachine
onready var _entity_container := $EntityContainer
onready var _gravity_line := $GravityLine


var initial_ship_position: Vector2
var initial_ship_rotation: float


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
	var debug_scene := get_tree().current_scene == self
	
	for entity in _entity_container.get_children():
		if entity.is_in_group(Globals.GROUP_SHIP):
			_ship = entity
			initial_ship_position = _ship.position
			initial_ship_rotation = _ship.rotation
			continue
			
		elif entity.is_in_group(Globals.GROUP_PLANET):
			_planets.append(entity)
			
		_initial_positions[entity] = entity.position
		_initial_rotations[entity] = entity.rotation
	
	for obj in get_children():
		if obj.is_in_group(Globals.GROUP_GOAL):
			_goal = obj
			break
			
	_level_state.setup(
		LevelState.NONE,
		funcref(self, "_on_LevelStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_LevelStateMachine_exit_state"))
	
	_goal.connect("body_entered", self, "_on_goal_body_entered")
			
	set_process(false)
	
	if debug_scene:
		Creator.setup(self)
		$Camera2D.current = true
		start_level(_ship)
	else:
		$Camera2D.queue_free()
		_ship.queue_free()
		_ship = null


func start_level(ship: KinematicBody2D):
	_ship = ship
	
	_level_state.set_state(LevelState.START)
	set_process(true)


func reset(immediate: bool):
	if immediate:
		for entity in _initial_positions.keys():
			entity.position = _initial_positions[entity]
		
		for entity in _initial_rotations.keys():
			entity.rotation = _initial_rotations[entity]
	else:
		for entity in _initial_positions.keys():
			get_tree().create_tween().tween_property(entity, "position", _initial_positions[entity], 1.0)
		
		for entity in _initial_rotations.keys():
			get_tree().create_tween().tween_property(entity, "rotation", _initial_rotations[entity], 1.0)
			
		yield(get_tree().create_timer(1.0), "timeout")
	
	_gravity_line.visible = false
	

func stop_level():
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
			if Input.is_action_just_pressed("start"):
				_ship_velocity = Vector2.RIGHT.rotated(_ship.rotation) * _ship_move_speed
				_level_state.set_state(LevelState.FLYING)
		
		LevelState.FLYING:			
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
				_level_state.set_state(LevelState.SHIP_DESTROYED)	
	

func _on_goal_body_entered(body: Node):
	if body.is_in_group(Globals.GROUP_SHIP):
		_level_state.set_state(LevelState.GOAL_REACHED)


func _on_LevelStateMachine_enter_state():
	match _level_state.current:
		LevelState.START:
			_ship.collision_enabled = true
			
		LevelState.GOAL_REACHED:
			_ship.collision_enabled = false
			_ship.booster_enabled = false
			
			State.goal_reached()
			
		LevelState.SHIP_DESTROYED:
			_ship.collision_enabled = false
			_ship.booster_enabled = false
			
			State.ship_destroyed()


func _on_LevelStateMachine_exit_state():
	match _level_state.current:
		LevelState.START:
			pass
