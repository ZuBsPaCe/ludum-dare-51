extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState


signal switch_game_state(new_state)
signal change_volume(music_factor, sound_factor)


onready var _menu_ship := get_node("%MenuShip")
onready var _menu_ship_small_offset := get_node("%MenuShipSmallOffset")
onready var _menu_ship_large_offset := get_node("%MenuShipLargeOffset")


var _music_slider: Slider
var _sound_slider: Slider

var _menu_ship_default_pos: Vector2
var _ship_small_offset := Vector2.ZERO
var _ship_large_offset := Vector2.ZERO


func _ready():
	# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
	if OS.has_feature("web"):
		get_node("%ExitButton").visible = false
	
	_music_slider = get_node("%MusicSlider")
	_sound_slider = get_node("%SoundSlider")

	_menu_ship_default_pos = _menu_ship.position
	
	restart_small_menu_ship_tween()
	restart_large_menu_ship_tween()
		
		

func setup(
		p_music_factor: float, 
		p_sound_factor: float):
	_music_slider.value = p_music_factor
	_sound_slider.value = p_sound_factor


func restart_small_menu_ship_tween():
	var offset := 1.0
	var ship_offset := Vector2(Globals.rand_effect.randf_range(-offset, offset), Globals.rand_effect.randf_range(-offset, offset))
	var tween := create_tween().tween_property(_menu_ship_small_offset, "position", ship_offset, ship_offset.length() / 30.0)
	tween.connect("finished", self, "restart_small_menu_ship_tween")
	
	
func restart_large_menu_ship_tween():	
	var offset := 40.0
	var ship_offset := Vector2(Globals.rand_effect.randf_range(-offset, offset), Globals.rand_effect.randf_range(-offset, offset))
	var tween := create_tween().tween_property(_menu_ship_large_offset, "position", ship_offset, ship_offset.length() / 20.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", self, "restart_large_menu_ship_tween")


func _process(_delta):
	_menu_ship.rotation = Globals.STAR_ANIM_SOURCE.angle_to_point(_menu_ship.global_position) + deg2rad(4)
	

func _on_StartButton_pressed():
	emit_signal("switch_game_state", GameState.GAME)


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_Volume_changed(_value):
	emit_signal(
		"change_volume", 
		_music_slider.value, 
		_sound_slider.value)
