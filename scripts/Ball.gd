extends RigidBody2D

signal glitch_win

onready var kick_sfx = $AudioStreamPlayer2D

func _ready():
	self.connect("body_entered", self, "_play_kick")

func _process(delta):
	if position.x < 0 or position.y < 0:
		emit_signal("glitch_win")

func _play_kick(_body):
	kick_sfx.play()
