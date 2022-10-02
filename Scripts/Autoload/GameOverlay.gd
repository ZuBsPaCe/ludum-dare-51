extends CanvasLayer


const GameState := preload("res://Scripts/GameState.gd").GameState

var _countdown

signal switch_game_state(new_state)


func _ready():
	_countdown = get_node("%Countdown")

func _on_MainMenuButton_pressed():
	emit_signal("switch_game_state", GameState.MAIN_MENU)
	

func set_countdown(time: float):
	_countdown.text = "%1.1f" % time
	
