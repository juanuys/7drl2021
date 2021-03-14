extends Node2D

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER:
			DungeonMaster.current_level = 1
			get_tree().change_scene("res://scripts/Menu.tscn")
