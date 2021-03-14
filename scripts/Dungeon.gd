extends Node2D

signal dungeon_initialised

onready var navmesh: Navigation2D = $Navigation2D
onready var level: TileMap = $Navigation2D/Level
onready var player = $Player
onready var player_vfx = $Player/Celebration
onready var ball = $Ball
onready var goal = $Goal
onready var goal_sfx = $Goal/SFX
onready var goal_vfx = $Goal/Celebration
onready var camera: Camera2D = $Player/Camera2D
onready var level_size = DungeonMaster.level_size

const FLOOR_TILE = 2
const WALL_TILE = 3

const EnemyScene = preload("res://scripts/Enemy.tscn")

func _ready() -> void:
	# uncomment to visualise the map from bird's eye view
	# _visualise_map()
	
	_initialise_dungeon()
	
	$Player/Aimer.connect("aim_complete", self, "_on_Aimer_aim_complete")
	
	# available Tile IDs
	#print("tile IDs ", level.tile_set.get_tiles_ids())
	#for i in level.tile_set.get_tiles_ids():
	#	print("tile name ", level.tile_set.tile_get_name(i))
	
	goal.connect("goal_scored", self, "_on_goal_scored")

func _on_Aimer_aim_complete(vec):
	# only kick if the ball is next to the player's feet
	if $Ball.position.distance_to($Player.position) < 30:
		$Ball.apply_impulse(Vector2(0,0), vec)

# use this to visualise the entire random map
func _visualise_map() -> void:
	camera = $Camera2D
	camera.current = true
	# converts a 2D vector from tile map coordinates to pixel coordinates
	camera.position = level.map_to_world(level_size / 2)
	var z := max(level_size.x, level_size.y) / 32
	camera.zoom = Vector2(z, z)


func _initialise_dungeon() -> void:
	"""
	Generate the random dungeon, and place the characters and props within it.
	"""
	
	# blank out the level with walls
	level.clear()
	for x in range(level_size.x):
		for y in range(level_size.y):
			level.set_cellv(Vector2(x, y), WALL_TILE)
	
	# the DM has a nice random level for us
	var data = DungeonMaster.generate_dungeon_layout_data()
	var data_keys = data.keys()

	# set tiles, enemies and props based on DM's level data
	for vector in data_keys:
		var item_at_coord = data[vector]
		if item_at_coord:  # could be null
			if item_at_coord.type == "enemy":
				var enemy = EnemyScene.instance()
				enemy.position = _snap_position(item_at_coord.grid_position)
				enemy.set_data(item_at_coord)
				$Enemies.add_child(enemy)
			
		level.set_cellv(vector, FLOOR_TILE)
	
	# fix bitmask, as set_cellv uses the *first* tile at region
	# but we want to *relevant* tile
	for x in range(level_size.x):
		for y in range(level_size.y):
			level.update_bitmask_area(Vector2(x, y))
	
	
	# TODO place player and ball in DM's generator
	# for now, place the player and their ball somewhere in the centre of the dungeon
	var mid = len(data_keys) / 2
	
	player.position = _snap_position(data_keys[mid])
	ball.position = _snap_position(data_keys[mid + 1])
	
	# TODO place the goal in the DM's generator
	goal.position = Vector2(128, 512)
	
	emit_signal("dungeon_initialised")
	
func _snap_position(pos):
	"""
	snapped() allows us to “round” the position to the nearest tile increment
	and adding a half-tile amount makes sure the player is centered on the tile.
	"""
	var _position = level.map_to_world(pos)
	_position = _position.snapped(Vector2.ONE * DungeonMaster.tile_size)
	_position += Vector2.ONE * DungeonMaster.tile_size/2
	return _position

func _on_goal_scored():
	goal_sfx.play()
	player_vfx.emitting = true
	goal_vfx.emitting = true
	
	var ball_tween = $Ball/Tween
	ball_tween.interpolate_property(
		$Ball/AnimatedSprite,
		"scale",
		$Ball/AnimatedSprite.scale,
		Vector2.ZERO,
		2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	ball_tween.start()
	ball_tween.connect("tween_completed", self, "_goto_next_level")
	
func _goto_next_level(_a, _b):
	# TODO show level number somewhere...
	DungeonMaster.current_level += 1
	get_tree().reload_current_scene()
