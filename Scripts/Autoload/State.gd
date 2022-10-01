extends Node


signal on_goal_reached(old_level_num, new_level_num)


var level := 1


func setup():
	pass


func on_game_start():
	print("State: Game started")
	
	level = 1


func on_game_stopped():
	print("State: Game stopped")


func goal_reached():
	var old_level := level
	level += 1
	emit_signal("on_goal_reached", old_level, level)
