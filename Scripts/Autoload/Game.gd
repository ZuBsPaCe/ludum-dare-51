extends Node2D


const GameState := preload("res://Scripts/GameState.gd").GameState


export(GameState) var _initial_game_state := GameState.MAIN_MENU


onready var _game_state := $GameStateMachine
onready var _ship := $Ship


export var star_anim_right_left_factor := 0.0
export var star_anim_top_down_factor := 0.0
export var star_anim_3d_factor := 1.0
export var star_anim_speed := 1.0


var _levels := {}


func _ready():
	Globals.setup()
	State.setup()
	Effects.setup($Camera2D, $StarContainer)
	Creator.setup(
		$ParticleContainer)
	
	set_fullscreen(Globals.get_setting(Globals.SETTING_FULLSCREEN))
	
	$MainMenu.setup(
		Globals.get_setting(Globals.SETTING_MUSIC_VOLUME),
		Globals.get_setting(Globals.SETTING_SOUND_VOLUME))
	
	$MainMenu.visible = false
	$GameOverlay.visible = false
	$Ship.visible = false
	
	$MainMenu.connect("switch_game_state", self, "switch_game_state")
	$MainMenu.connect("change_volume", self, "change_volume")
	$GameOverlay.connect("switch_game_state", self, "switch_game_state")
	
	State.connect("on_goal_reached", self, "on_goal_reached")
	State.connect("on_ship_destroyed", self, "on_ship_destroyed")
	
	get_tree().connect("screen_resized", self, "on_screen_resized")
	
	var level_index := 0
	for level in $Levels.get_children():
		level_index += 1
		_levels[level_index] = level
		Tools.remove_from_parent(level)
	
	_update_star_anim_properties()
	
	
	Effects.create_star_layer(1)
	Effects.create_star_layer(2)
	Effects.create_star_layer(3)
	
	_game_state.setup(
		_initial_game_state,
		funcref(self, "_on_GameStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_GameStateMachine_exit_state"))


func _process(_delta):
	_update_star_anim_properties()
		
	if _game_state.current != GameState.GAME:
		return
	
#	$Dummy.position += $Dummy.position.direction_to(Globals.get_global_mouse_position()) * 100.0 * delta
#	$Dummy.rotation = -PI * 0.5 + $Dummy.position.angle_to_point(Globals.get_global_mouse_position())


func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo and event.alt and event.scancode == KEY_ENTER:
			set_fullscreen(!OS.window_fullscreen)


func on_screen_resized():
	if !OS.window_fullscreen:
		Globals.set_setting(Globals.SETTING_WINDOW_WIDTH, OS.window_size.x)
		Globals.set_setting(Globals.SETTING_WINDOW_HEIGHT, OS.window_size.y)
		Globals.save_settings()
		

func switch_game_state(new_state):
	_game_state.set_state(new_state)

func switch_game_state_to_game():
	switch_game_state(GameState.GAME)


func on_goal_reached(old_level_num: int, new_level_num: int):
	stop_level(old_level_num)
	
	if !start_level(new_level_num):
		switch_game_state(GameState.MAIN_MENU)
		
func on_ship_destroyed():
	restart_level()
	

func stop_level(level_num: int):
	var level = _levels[level_num]
	
	level.stop_level()
	Tools.remove_from_parent(level)
	
	
func start_level(level_num: int) -> bool:
	if not _levels.has(level_num):
		return false
	
	var level = _levels[level_num]
	
	Tools.set_new_parent(level, $Levels)
	level.reset(true)
	level.modulate.a = 0.0
	level.visible = true
	
	get_tree().create_tween().tween_property(level, "modulate", Color.white, 1.0)
	
	yield(move_ship_to_start(), "completed")
	
	level.start_level(_ship)
	return true
	

func restart_level():
	var level = _levels[State.level]
	
	level.reset(false)
	yield(move_ship_to_start(), "completed")
	level.start_level(_ship)


func set_fullscreen(enabled: bool):		
	if OS.window_fullscreen == enabled:
		return
	
	OS.window_fullscreen = enabled
	
	if !OS.window_fullscreen:
		OS.window_size = Vector2(
			Globals.get_setting(Globals.SETTING_WINDOW_WIDTH),
			Globals.get_setting(Globals.SETTING_WINDOW_HEIGHT))
	
	Globals.set_setting(Globals.SETTING_FULLSCREEN, OS.window_fullscreen)
	Globals.save_settings()


func change_volume(music_factor: float, sound_factor: float):
	AudioServer.set_bus_volume_db(1, linear2db(music_factor))
	AudioServer.set_bus_volume_db(2, linear2db(sound_factor))
	
	Globals.set_setting(Globals.SETTING_MUSIC_VOLUME, music_factor)
	Globals.set_setting(Globals.SETTING_SOUND_VOLUME, sound_factor)
	Globals.save_settings()


func move_ship_to_start():
	var level = _levels[State.level]
	
	var canvas_size := Tools.get_canvas()
	
	var initial_ship_position: Vector2 = level.initial_ship_position
	var initial_ship_rotation: float = level.initial_ship_rotation
	
	var enter_ship_positions := [
		Vector2(Globals.canvas_rect.position.x - 100.0, initial_ship_position.y),
		Vector2(Globals.canvas_rect.end.x - 100.0, initial_ship_position.y),
		Vector2(initial_ship_position.x, Globals.canvas_rect.position.y - 100.0),
		Vector2(initial_ship_position.x, Globals.canvas_rect.end.y + 100.0),
	]
	
	var enter_ship_position: Vector2
	var test_dist := -1.0
	
	for test_position in enter_ship_positions:
		var current_dist: float = initial_ship_position.distance_to(test_position)
		if test_dist < 0.0 || current_dist < test_dist:
			test_dist = current_dist
			enter_ship_position = test_position
	
	_ship.collision_enabled = false
	_ship.booster_enabled = false
	
	_ship.position = enter_ship_position
	_ship.rotation = initial_ship_rotation
	_ship.visible = true
	
	var tween := get_tree().create_tween().tween_property(_ship, "position", initial_ship_position, 1.0)
	yield(tween, "finished")


func _on_GameStateMachine_enter_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenu.visible = true
			
		GameState.INTRO:
			$TransitionAnimationPlayer.play("Intro")
			

		GameState.GAME:
			State.on_game_start()
			$GameOverlay.visible = true
			
			start_level(1)


func _on_GameStateMachine_exit_state():
	match _game_state.current:
		GameState.INTRO:
			$MainMenu.visible = false

		GameState.GAME:
			State.on_game_stopped()
			$GameOverlay.visible = false


func _on_MainMenu_intro_anim_finished():
	_game_state.set_state()


func _update_star_anim_properties():
	Globals.star_anim_3d_factor = star_anim_3d_factor
	Globals.star_anim_right_left_factor = star_anim_right_left_factor
	Globals.star_anim_speed = star_anim_speed
	Globals.star_anim_top_down_factor = star_anim_top_down_factor
