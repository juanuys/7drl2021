extends RigidBody2D

signal glitch_win

func _process(delta):
	if position.x < 0 or position.y < 0:
		emit_signal("glitch_win")
