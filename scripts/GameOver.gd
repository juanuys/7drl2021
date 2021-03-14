extends Node2D

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER:
			DungeonMaster.reset()
			get_tree().change_scene("res://scripts/Menu.tscn")
