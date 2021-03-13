extends KinematicBody2D

signal player_hit(health)
signal player_die
signal player_moved

export var speed = 100  # How fast the player will move (pixels/sec).
export var health := 3
var screen_size
onready var ray = $RayCast2D
onready var tween = $Tween
onready var anim = $AnimatedSprite

var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite.animation = "idle"

func _process(delta):
	if DungeonMaster.is_turned_based():
		return
	
	_continuous_move(delta)

func _continuous_move(delta):
	var velocity = Vector2()  # The player's movement vector.
	var moved := false
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		$AnimatedSprite.flip_h = false
		moved = true
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		$AnimatedSprite.flip_h = true
		moved = true
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		moved = true
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		moved = true
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	if moved:
		emit_signal("player_moved")

func _unhandled_input(event):
	if not DungeonMaster.is_turned_based():
		return
	if tween.is_active():
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			if dir == "ui_left":
				anim.flip_h = true
			if dir == "ui_right":
				anim.flip_h = false
			move(dir)

func move(dir):
	ray.cast_to = inputs[dir] * DungeonMaster.tile_size
	# When changing a raycast’s cast_to property, the physics engine won’t
	# recalculate its collisions until the next physics frame.
	# force_raycast_update() lets you update the ray’s state immediately. 
	ray.force_raycast_update()
	if !ray.is_colliding():
		# position += inputs[dir] * tile_size
		move_tween(dir)
		emit_signal("player_moved")


func move_tween(dir):
	tween.interpolate_property(
		self,
		"position",
		position,
		position + inputs[dir] * DungeonMaster.tile_size,
		0.1,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.start()


func _on_Area2D_area_entered(area):
	health -= 1
	emit_signal("player_hit", [health])
	if health <= 0:
		emit_signal("player_die")

