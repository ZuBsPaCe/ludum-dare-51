extends CanvasLayer


const GameState := preload("res://Scripts/GameState.gd").GameState

onready var _tutorial_mouse := $MarginContainer/VBoxContainer/HBoxContainer/TutorialMouse
onready var _tutorial_joypad := $MarginContainer/VBoxContainer/HBoxContainer/TutorialJoyPad

var _countdown
var _last_time := 10.0

signal switch_game_state(new_state)


func _ready():
	_countdown = get_node("%Countdown")
	

func _process(delta):
	# Controller support was added post compo
	var valid_action := true
	if !Globals.using_post_compo_version:
		valid_action = Globals.is_valid_compo_button()
	
	if valid_action and Input.is_action_just_pressed("main_menu"):
		emit_signal("switch_game_state", GameState.MAIN_MENU)
	
	_tutorial_mouse.visible = !Globals.using_joypad
	_tutorial_joypad.visible = Globals.using_joypad
	

func _on_MainMenuButton_pressed():
	emit_signal("switch_game_state", GameState.MAIN_MENU)
	

func set_countdown(time: float):
	_countdown.text = "%1.1f" % time
	_countdown.visible = true
	
	if time <= 3.0:
		_countdown.modulate.g = 0.0
		_countdown.modulate.b = 0.0
		
		_countdown.rect_scale = Vector2(1.2, 1.2)

	else:
		_countdown.modulate.g = 1.0
		_countdown.modulate.b = 1.0
		
		_countdown.rect_scale = Vector2.ONE
	
	_last_time = time
	

func set_countdown_visible(state: bool):
	_countdown.visible = state
