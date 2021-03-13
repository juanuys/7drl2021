extends Node2D

onready var navmesh = get_parent().get_node("Navigation2D")
onready var player = get_parent().get_node("Player")

func _ready():
	get_parent().connect("dungeon_initialised", self, "_on_Dungeon_dungeon_initialised")
	player.connect("player_moved", self, "_on_Player_player_moved")

func _on_Dungeon_dungeon_initialised():
	print("enemies ", get_child_count())

func _get_path_from_me_to_player(me: Vector2) -> PoolVector2Array:
	var path: PoolVector2Array = navmesh.get_simple_path(me, player.position)
	return path

func _on_Player_player_moved():
	for enemy in get_children():
		var path: PoolVector2Array = _get_path_from_me_to_player(enemy.position)
		enemy.set_path(path)
