extends Node2D

onready var play_classic = $PlayClassic
onready var play_fast = $PlayFast

# get the healthbar just so we can delete it
# (which hints that we ought to probably dissociate it from player scene)
onready var healthbar = $Player/HealthBar

export(String, FILE, "*.tscn") var next_scene_path


func _ready():
	play_classic.connect("goal_scored", self, "_play_classic")
	play_fast.connect("goal_scored", self, "_play_fast")
	healthbar.queue_free()

func _play_fast():
	print("play fast")
	DungeonMaster.turned_based = false
	get_tree().change_scene(next_scene_path)

func _play_classic():
	print("play classic")
	DungeonMaster.turned_based = true
	get_tree().change_scene(next_scene_path)
