extends KinematicBody2D

# for when GD.turn_based == false
export var speed := 50  # How fast the enemy will move (pixels/sec).

var path := PoolVector2Array() setget set_path
var attributes := {}
var data: DungeonItemData
onready var tween = $Tween

func _ready() -> void:
	set_process(false)

func set_data(data_: DungeonItemData):
	data = data_

func _process(delta: float) -> void:
	if DungeonMaster.is_turned_based():
		return
	
	var move_distance := speed * delta
	_move_along_path(move_distance)

func _move_along_path(distance: float) -> void:
	var last_point : = position
	for index in range(path.size()):
		var distance_to_next = last_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = last_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif path.size() == 1 and distance >= distance_to_next:
			position = path[0]
			set_process(false)
			break

		distance -= distance_to_next
		last_point = path[0]
		path.remove(0)

func set_path(value: PoolVector2Array) -> void:
	if value.size() == 0:
		return
	path = value
	path.remove(0)
	set_process(true)
	
	_take_turn()


func _take_turn():
	if not DungeonMaster.is_turned_based():
		return
	
	if tween.is_active():
		return
		
	# TODO give enemies move_points and make them move slower
	# (e.g. every other turn)
	
	var direction = position.direction_to(path[0])
	
	# TODO doesn't work that well (collision areas to large on enemies?)
	#move_tween(_quantize_vector(direction))
	move_tween(direction)


# quantizes a continuous vector into integer vector
func _quantize_vector(vec: Vector2) -> Vector2:
	var r = vec.normalized().rotated(deg2rad(-45))
	# rotate a quarter, to make checks easy
	if r.y < 0:
		return Vector2.RIGHT if r.x >= 0 else Vector2.UP
	else:
		return Vector2.DOWN if r.x >= 0 else Vector2.LEFT
			

func move_tween(dir: Vector2):
	tween.interpolate_property(
		self,
		"position",
		position,
		position + dir * DungeonMaster.tile_size,
		0.1,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.start()


func _on_Area2D_area_entered(area):
	# enemy area2d collision mask is set to ignore other enemies,
	# so the only thing that can collide here is the player
	# or ball, and in both cases, they lose a health point
	# But for now, they just die.

	tween.interpolate_property(
		self,
		"scale",
		scale,
		Vector2.ZERO,
		0.1,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.start()
	tween.connect("tween_completed", self, "_die")

func _die(obj, key):
	queue_free()
