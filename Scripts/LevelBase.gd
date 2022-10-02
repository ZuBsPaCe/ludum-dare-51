extends Node2D


const LevelState := preload("res://Scripts/LevelState.gd")


onready var _level_state := $LevelStateMachine
onready var _entity_container := $EntityContainer
onready var _visuals_container := $VisualsContainer


var initial_ship_position: Vector2
var initial_ship_rotation: float


var _ship: KinematicBody2D
var _planets: Array
var _asteroids: Array
var _goal: Area2D


var _initial_positions: Dictionary
var _initial_rotations: Dictionary

var _ship_move_speed := 350.0
var _ship_turn_speed := PI

var _ship_velocity := Vector2.ZERO

var _locked_planet: KinematicBody2D
var _locked_distance: float

var _gravity_lines := {}

var _shoot_cooldown := Cooldown.new()
var _shoot_right := true


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
			
		elif entity.is_in_group(Globals.GROUP_ASTEROID):
			_asteroids.append(entity)
			
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
	
	_shoot_cooldown.setup(self, 0.05, true)
	
	_goal.connect("body_entered", self, "_on_goal_body_entered")
			
	set_process(false)
	
	if debug_scene:
		Creator.setup(self, self)
		$Camera2D.current = true
		start_level(_ship)
	else:
		$Camera2D.queue_free()
		_ship.queue_free()
		_ship = null


func start_level(ship: KinematicBody2D):
	_ship = ship
	_shoot_right = true
	
	_level_state.set_state(LevelState.START)
	set_process(true)


func reset(immediate: bool):
	for entity in _asteroids:
		entity.set_collision_enabled(false)
	
	if immediate:
		for entity in _initial_positions.keys():
			entity.set_process(false)
			entity.position = _initial_positions[entity]
		
		for entity in _initial_rotations.keys():
			entity.rotation = _initial_rotations[entity]
	else:
		for entity in _initial_positions.keys():
			entity.set_process(false)
			get_tree().create_tween().tween_property(entity, "position", _initial_positions[entity], 1.0)
		
		for entity in _initial_rotations.keys():
			get_tree().create_tween().tween_property(entity, "rotation", _initial_rotations[entity], 1.0)
			
		yield(get_tree().create_timer(1.0), "timeout")
	
	for entity in _initial_positions.keys():
			entity.set_process(true)
			
	for entity in _asteroids:
		entity.set_collision_enabled(true)
		entity.reset_health()
			
	_shoot_right = true
	

func stop_level():
	set_process(false)

var dbg := 0.0

func _process(delta: float):		
	var nearest_planet = null
	var nearest_distance = -1.0
	
	for planet in _planets:
		var distance = _ship.position.distance_to(planet.position)
		if nearest_distance < 0.0 || distance < nearest_distance:
			nearest_planet = planet
			nearest_distance = distance
			
	
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
				
			var look_direction = Vector2.RIGHT.rotated(_ship.rotation)
				
			
			var planet_forces := Vector2.ZERO
			
			
			for planet in _planets:
				var inner_radius: float = 512.0 * planet.scale.x
				var affect_distance: float = 400.0#inner_radius * 2.0
				var outer_radius := inner_radius + affect_distance
				
				var planet_vec: Vector2 = planet.position - _ship.position
				var distance: float = planet_vec.length()
				
				var force := 1.0 - clamp((distance - inner_radius) / affect_distance, 0.0, 1.0)
				
				var gravity_line: Node2D
				
				if !_gravity_lines.has(planet):
					gravity_line = Creator.create_gravity_line(_visuals_container)
					_gravity_lines[planet] = gravity_line
				else:
					gravity_line = _gravity_lines[planet]
					
				if force > 0.0:
					#force = force * force
					planet_forces += planet_vec.normalized() * force * 1000.0
				
					gravity_line.visible = true
					gravity_line.position = planet.position
					gravity_line.rotation = _ship.position.angle_to_point(planet.position)
					gravity_line.scale.x = distance / 64.0
					gravity_line.modulate.a = force
				else:
					gravity_line.visible = false
			
			_ship_velocity += (booster_force + planet_forces) * delta
			
			var reset := false
			if _ship.move_and_collide(_ship_velocity * delta):
				reset = true
			elif !Tools.get_visible_rect().has_point(_ship.position):
				reset = true
			
			if reset:
				Creator.create_explosion(_ship.position, _ship_velocity * 0.5)
				Globals.sound.play(Globals.SOUND_KILLED, _ship.position)
				
				_level_state.set_state(LevelState.SHIP_DESTROYED)
				return
			
			if Input.is_action_pressed("shoot") and _shoot_cooldown.done:
				_shoot_cooldown.restart()
				
				var bullet_offset: Vector2
				if _shoot_right:
					bullet_offset = look_direction.rotated(PI * 0.5) * 8.0
				else:
					bullet_offset = look_direction.rotated(-PI * 0.5) * 8.0
					
				_shoot_right = !_shoot_right
								
				Creator.create_bullet(_ship.position + bullet_offset + look_direction * 32.0, look_direction * 1024.0)
				_ship.start_shoot_sound()
	

func _on_goal_body_entered(body: Node):
	if body.is_in_group(Globals.GROUP_SHIP):
		_level_state.set_state(LevelState.GOAL_REACHED)


func _on_LevelStateMachine_enter_state():
	match _level_state.current:
		LevelState.START:
			_ship.collision_enabled = true
			
		LevelState.GOAL_REACHED:
			_cleanup()
			
			State.goal_reached()
			
		LevelState.SHIP_DESTROYED:
			_cleanup()
			
			State.ship_destroyed()


func _cleanup():
	_ship.collision_enabled = false
	_ship.booster_enabled = false
	
	for gravity_line in _gravity_lines.values():
		gravity_line.queue_free()
	_gravity_lines.clear()
	

func _on_LevelStateMachine_exit_state():
	match _level_state.current:
		LevelState.START:
			pass
