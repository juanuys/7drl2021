extends Node2D

signal goal_scored

func _ready():
	pass

func _on_Area2D_area_entered(area):
	# the mask for this is set to ball
	emit_signal("goal_scored")
