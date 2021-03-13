extends Control

onready var player = get_parent()
onready var vps = get_viewport().size

func _ready():
	margin_top = -vps.y/2
	margin_left = -vps.x/2
	player.connect("player_moved", self, "_on_Player_player_moved")
	player.connect("player_hit", self, "_on_Player_player_hit")
	
	for i in range(player.health):
		var heart = $heart.duplicate()
		heart.visible = true
		heart.margin_left = i * 32
		add_child(heart)

func _on_Player_player_moved():
	margin_top = -vps.y/2
	margin_left = -vps.x/2

func _on_Player_player_hit(health):
	var heart = get_children().pop_back()
	if heart:
		heart.queue_free()
