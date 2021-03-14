# Game singleton, which sets up some rules

extends Node

var turned_based = true

const level_size := Vector2(100, 80)
const rooms_size := Vector2(10, 14)
const rooms_max := 15
const tile_size := 16
var current_level = 1

var enemy_attributes = preload("res://resources/EnemyAttributes.gd").new()
const DungeonItemData = preload("res://scripts/DungeonItemData.gd")

# When this stays the same, the game randomness will always play the predictable.
var game_rng_seed = "7drl" setget set_seed
# Game random number generator
var game_rng := RandomNumberGenerator.new()


func is_turned_based():
	# for some reason I can't just call DM.turn_based elsewhere,
	# hence this func
	return turned_based


func _ready():
	print("Dungeon Master is present", enemy_attributes)
	set_seed(game_rng_seed)


# Setter for the random seed.
func set_seed(_seed) -> void:
	game_rng_seed = str(_seed)
	game_rng.set_seed(hash(game_rng_seed))


func generate_dungeon_layout_data() -> Dictionary:
	# uncomment the following line to skip the seed, and randomise with a time-based seed
	# game_rng.randomize()

	var data := {}
	var rooms := []
	for room_idx in range(rooms_max):
		var room := _get_random_room()
		if _intersects(rooms, room):
			continue

		_add_room(data, rooms, room, room_idx)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(data, room_previous, room)
	return data


func _get_random_room() -> Rect2:
	var width := game_rng.randi_range(rooms_size.x, rooms_size.y)
	var height := game_rng.randi_range(rooms_size.x, rooms_size.y)
	var x := game_rng.randi_range(0, level_size.x - width - 1)
	var y := game_rng.randi_range(0, level_size.y - height - 1)
	var room_rect = Rect2(x, y, width, height)
	return room_rect


func _add_room(data: Dictionary, rooms: Array, room: Rect2, room_idx: int) -> void:
	rooms.push_back(room)
	
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			data[Vector2(x, y)] = null
	
	var n_items = game_rng.randi_range(
		DungeonMaster.current_level,
		DungeonMaster.current_level + 2)
	
	var random_points = {}
	for i in range(n_items):
		while true:
			var rx = game_rng.randi_range(room.position.x, room.end.x - 1)
			var ry = game_rng.randi_range(room.position.y, room.end.y - 1)
			var rxy = Vector2(rx, ry)
			if random_points.has(rxy):
				continue
			random_points[rxy] = null
			break
				
	for random_point in random_points.keys():
		data[random_point] = _get_random_item_or_enemy(room_idx, room, random_point)


func _get_random_item_or_enemy(room_idx, room, vec):
	"""
	Looks at current_level to determine which enemies, and how
	many of them to place in the dungeon.
	Maybe also items/props.
	
	We read enemy attributes here, as we might want to buff/nerf them
	as a function of current_level.
	
	DM provides pure data, and Dungeon.gd will link the appropriate scenes.
	"""
	var types = enemy_attributes.keys()
	var type = types[game_rng.randi_range(0, len(types) - 1)]
	return DungeonItemData.new(
					type,
					enemy_attributes.get(type),
					"enemy",
					vec)


func _add_connection(data: Dictionary, room1: Rect2, room2: Rect2) -> void:
	var room_center1 := (room1.position + room1.end) / 2
	var room_center2 := (room2.position + room2.end) / 2
	if game_rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)


func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X: point = Vector2(t, constant)
			Vector2.AXIS_Y: point = Vector2(constant, t)

		if not data.has(point):
			data[point] = null
		
		# make the corridor wider (brute force)
		for i in [-1, 1]:
			for j in [-1, 1]:
				var newpoint = point + Vector2(i,j)
				if not data.has(newpoint):
					data[newpoint] = null
		

func _intersects(rooms: Array, room: Rect2) -> bool:
	var out := false
	for room_other in rooms:
		if room.intersects(room_other):
			out = true
			break
	return out
