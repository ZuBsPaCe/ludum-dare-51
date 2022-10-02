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
		intensity = 5.0, 
		frequency = 20.0, 
		duration = 0.5) -> void:
	_camera.start_shake(dir, intensity, frequency, duration)


	

func create_star_layer(p_layer: int):
	var container := Node2D.new()
	_star_container.add_child(container)
	
	var count: int
	var frames: Array
	var alpha: float
	var speed_factor: float
	var scale: float
	
	match p_layer:
		1:
			count = 100
			frames = [0, 1, 2]
			alpha = 1.0
			speed_factor = 1.0
			scale = 4.0
		2:
			count = 50
			frames = [0, 1, 2, 3, 4, 5]
			alpha = 0.5
			speed_factor = 0.8
			scale = 3.0
		3:
			count = 20
			frames = [3, 4, 5, 6, 7]
			alpha = 0.25
			speed_factor = 0.6
			scale = 2.0
		_:
			assert(false)
	
	var blink = int(count / 5.0)
	
	for i in range(count):
		Creator.create_star(
			container,
			frames[Globals.rand_effect.randi() % frames.size()],
			i < blink,
			Globals.rand_effect.randf(),
			speed_factor,
			scale)
	
	container.modulate.a = alpha
