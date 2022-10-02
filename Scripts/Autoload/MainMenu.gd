extends Node2D


const GameState := preload("res://Scripts/GameState.gd").GameState


signal switch_game_state(new_state)
signal change_volume(music_factor, sound_factor)


onready var _menu_ship := get_node("%MenuShip")
onready var _menu_ship_small_offset := get_node("%MenuShipSmallOffset")
onready var _menu_ship_large_offset := get_node("%MenuShipLargeOffset")

onready var _title_root := get_node("%TitleRoot")
onready var _title_avoid_root := get_node("%TitleAvoidRoot")
onready var _title_asteroid_root := get_node("%TitleAsteroidRoot")

onready var _title_avoid_blur := get_node("%AvoidBlur")
onready var _title_asteroid_blur := get_node("%AsteroidBlur")


var _music_slider: Slider
var _sound_slider: Slider

#var _ship_small_offset := Vector2.ZERO
#var _ship_large_offset := Vector2.ZERO
#
#var _title_avoid_offset := Vector2.ZERO
#var _title_asteroid_offset := Vector2.ZERO


func _ready():
	# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
	if OS.has_feature("web"):
		get_node("%ExitButton").visible = false
	
	_music_slider = get_node("%MusicSlider")
	_sound_slider = get_node("%SoundSlider")
	
	restart_small_menu_ship_tween()
	restart_large_menu_ship_tween()
	
	restart_title_tween()
	restart_title_avoid_tween()
	restart_title_asteroid_tween()
	restart_title_scale_tween()
		
		

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


func restart_title_avoid_tween():	
	var offset := 10.0
	var offset_vec := Vector2(Globals.rand_effect.randf_range(-offset, offset), Globals.rand_effect.randf_range(-offset, offset))
	var tween := create_tween().tween_property(_title_avoid_root, "position", offset_vec, offset_vec.length() / 5.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", self, "restart_title_avoid_tween")
	

func restart_title_asteroid_tween():	
	var offset := 10.0
	var offset_vec := Vector2(Globals.rand_effect.randf_range(-offset, offset), Globals.rand_effect.randf_range(-offset, offset))
	var tween := create_tween().tween_property(_title_asteroid_root, "position", offset_vec, offset_vec.length() / 5.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", self, "restart_title_asteroid_tween")
	

func restart_title_tween():	
	var offset := 20.0
	var offset_vec := Vector2(Globals.rand_effect.randf_range(-offset, offset), Globals.rand_effect.randf_range(-offset, offset))
	var tween := create_tween().tween_property(_title_root, "position", offset_vec, offset_vec.length() / 5.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", self, "restart_title_tween")
	

func restart_title_scale_tween():	
	var scale_factor := Globals.rand_effect.randf_range(1.0, 1.05)
	var scale_mount := Vector2(scale_factor, scale_factor + (scale_factor - 1.0) * 3.0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_title_avoid_blur, "scale", scale_mount, scale_mount.length() / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_title_asteroid_blur, "scale", scale_mount, scale_mount.length() / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", self, "restart_title_scale_tween")

func set_visible_hack(root: bool, menu: bool):
	visible = root
	$MainMenu.visible = menu
	$Title.visible = menu
	
func reset_anim():
	$AnimationPlayer.play("RESET")


func _process(_delta):
	_menu_ship.rotation = Globals.STAR_ANIM_SOURCE.angle_to_point(_menu_ship.global_position) + deg2rad(4)
	

func _on_StartButton_pressed():
	emit_signal("switch_game_state", GameState.INTRO)


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_Volume_changed(_value):
	emit_signal(
		"change_volume", 
		_music_slider.value, 
		_sound_slider.value)

