extends Node2D


func _ready():
	pass

func _on_Area2D_area_entered(area):
	# the mask for this is set to ball
	print("You won!")
