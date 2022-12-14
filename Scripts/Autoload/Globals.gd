extends Node

const TILE_SIZE := 16.0
const HALF_TILE_SIZE := TILE_SIZE / 2.0

const canvas_size := Vector2(1920, 1080)
const canvas_rect := Rect2(canvas_size / -2.0, canvas_size)
const larger_canvas_rect :=  Rect2((canvas_size + Vector2(10.0, 10.0)) / -2.0, canvas_size + Vector2(10.0, 10.0))

const SETTING_FULLSCREEN := "Fullscreen"
const SETTING_WINDOW_WIDTH := "Window Width"
const SETTING_WINDOW_HEIGHT := "Window Height"
const SETTING_MUSIC_VOLUME := "Music"
const SETTING_SOUND_VOLUME := "Sound"
const SETTING_POST_COMPO := "PostCompoVersion"
const SETTING_EASY_DIFFICULTY := "EasyDifficulty"

const GROUP_SHIP := "Ship"
const GROUP_PLANET := "Planet"
const GROUP_GOAL := "Goal"
const GROUP_BULLET := "Bullet"
const GROUP_ASTEROID := "Asteroid"

const STAR_ANIM_SOURCE := Vector2(400.0, -100)


const SOUND_SHOOT := "Shoot"
const SOUND_BULLET_HIT := "BulletHit"
const SOUND_ASTEROID_DESTROYED := "AsteroidDestroyed"
const SOUND_KILLED := "Killed"

var rand_effect := RandomNumberGenerator.new()
var rand_asteroid := RandomNumberGenerator.new()

var sound

var _center_node: Node2D
var _settings: Dictionary

var star_anim_right_left_factor: float
var star_anim_top_down_factor: float
var star_anim_3d_factor: float
var star_anim_speed := 0.0

# Prevent Alt+Enter from starting game or something
var fullscreen_switching := false

var using_joypad := false

var using_post_compo_version := false
var easy_difficulty := false

func _ready():
	_center_node = Node2D.new()
	add_child(_center_node)


func setup():
	_settings = {
		Globals.SETTING_FULLSCREEN: true,
		Globals.SETTING_WINDOW_WIDTH: OS.get_screen_size().x / 2,
		Globals.SETTING_WINDOW_HEIGHT: OS.get_screen_size().y / 2,
		Globals.SETTING_MUSIC_VOLUME: 0.8,
		Globals.SETTING_SOUND_VOLUME: 0.8,
		Globals.SETTING_POST_COMPO: false,
		Globals.SETTING_EASY_DIFFICULTY: false
	}
	
	Tools.load_data("settings.json", _settings)
	
	Globals.using_post_compo_version = Globals.get_setting(Globals.SETTING_POST_COMPO)
	Globals.easy_difficulty = Globals.get_setting(Globals.SETTING_EASY_DIFFICULTY)


func get_setting(name: String):
	return _settings[name]


func set_setting(name: String, value):
	_settings[name] = value


func save_settings():
	Tools.save_data("settings.json", _settings)


func get_global_mouse_position() -> Vector2:
	return _center_node.get_global_mouse_position()


func is_valid_compo_button():
	return (
		Input.is_mouse_button_pressed(BUTTON_LEFT) or
		Input.is_mouse_button_pressed(BUTTON_RIGHT) or
		Input.is_key_pressed(KEY_SPACE) or
		Input.is_key_pressed(KEY_CONTROL))
