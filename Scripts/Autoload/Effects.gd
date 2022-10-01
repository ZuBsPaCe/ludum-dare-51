extends Node

var _camera: Camera2D
var _star_container: Node2D


func setup(
		p_camera: Camera2D,
		p_star_container: Node2D):
	_camera = p_camera
	_star_container = p_star_container


func shake(
		dir: Vector2, 
		intensity = 10.0, 
		frequency = 20.0, 
		duration = 0.5) -> void:
	_camera.start_shake(dir, intensity, frequency, duration)
	

func create_star_layer(p_layer: int):
	var container := Node2D.new()
	_star_container.add_child(container)
	
	var count: int
	var frames: Array
	var alpha: float
	
	match p_layer:
		1:
			count = 100
			frames = [0, 1, 2]
			alpha = 1.0
		2:
			count = 50
			frames = [0, 1, 2, 3, 4, 5]
			alpha = 0.5
		3:
			count = 20
			frames = [3, 4, 5, 6, 7]
			alpha = 0.25
		_:
			assert(false)
	
	var blink = int(count / 5.0)
	
	var viewport_size := get_viewport().size
	var min_x := -int(viewport_size.x / 2.0)
	var max_x := +int(viewport_size.x / 2.0)
	var min_y := -int(viewport_size.y / 2.0)
	var max_y := +int(viewport_size.y / 2.0)
	
	for i in range(count):
		Creator.create_star(Vector2(
			Globals.rand_effect.randi_range(min_x, max_x),
			Globals.rand_effect.randi_range(min_y, max_y)),
			container,
			frames[Globals.rand_effect.randi() % frames.size()],
			i < blink)
	
	container.modulate.a = alpha
