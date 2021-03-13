"""
Represents a thing you might find in the dungeon, apart from
player and ball.
E.g. enemy, props, potions, etc

The consumer would check the type, and handle attributes dict accordingly.
E.g. a zombie will have attack points, and a potion would have health boost.
"""

class_name DungeonItemData
extends Resource

var name: String
var attributes: Dictionary
var type: String
var grid_position: Vector2

func _init(name_, attributes_, type_, grid_position_):
	name = name_
	attributes = attributes_
	type = type_
	grid_position = grid_position_
