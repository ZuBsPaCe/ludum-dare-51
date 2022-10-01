extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState


export(GameState) var _initial_game_state := GameState.MAIN_MENU


onready var _game_state := $GameStateMachine


var _levels := {}


func _ready():
	Globals.setup()
	State.setup()
	Effects.setup($Camera2D)
	Creator.setup($ParticleContainer)
	
	set_fullscreen(Globals.get_setting(Globals.SETTING_FULLSCREEN))
	
	$MainMenu.setup(
		Globals.get_setting(Globals.SETTING_MUSIC_VOLUME),
		Globals.get_setting(Globals.SETTING_SOUND_VOLUME))
	
	$MainMenu.visible = false
	$GameOverlay.visible = false
	
	$MainMenu.connect("switch_game_state", self, "switch_game_state")
	$MainMenu.connect("change_volume", self, "change_volume")
	$GameOverlay.connect("switch_game_state", self, "switch_game_state")
	
	State.connect("on_goal_reached", self, "on_goal_reached")
	
	get_tree().connect("screen_resized", self, "on_screen_resized")
	
	var level_index := 0
	for level in $Levels.get_children():
		level_index += 1
		_levels[level_index] = level
		Tools.remove_from_parent(level)
	
	_game_state.setup(
		_initial_game_state,
		funcref(self, "_on_GameStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_GameStateMachine_exit_state"))


func _process(_delta):
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


func on_goal_reached(old_level_num: int, new_level_num: int):
	stop_level(old_level_num)
	
	if !start_level(new_level_num):
		switch_game_state(GameState.MAIN_MENU)


func stop_level(level_num: int):
	var level = _levels[level_num]
	
	level.stop_level()
	Tools.remove_from_parent(level)
	
	
func start_level(level_num: int) -> bool:
	if not _levels.has(level_num):
		return false
	
	var level = _levels[level_num]
	
	Tools.set_new_parent(level, $Levels)
	level.start_level()
	level.visible = true
	return true


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


func _on_GameStateMachine_enter_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenu.visible = true

		GameState.GAME:
			State.on_game_start()
			$GameOverlay.visible = true
			
			start_level(1)

		_:
			assert(false, "Unknown game state")


func _on_GameStateMachine_exit_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenu.visible = false

		GameState.GAME:
			State.on_game_stopped()
			$GameOverlay.visible = false

		_:
			assert(false, "Unknown game state")
