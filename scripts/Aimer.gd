extends Node2D

signal aim_complete(vec)
signal initiated_targeting

var aim_vector = Vector2(0,0)
export var color: Color = Color(0, 255 , 100)
export var width: float = 3.0

func _ready():
	hide()
	
func _draw():
	draw_line(Vector2(0,0), aim_vector, color, width, true)

func _process(_delta: float) -> void:
	if visible:
		aim_vector = get_global_mouse_position() - get_parent().global_position
		update()

func initiate_targeting() -> void:
	show()
	emit_signal("initiated_targeting")

func complete_targeting() -> void:
	hide()
	emit_signal("aim_complete", aim_vector)
	aim_vector = Vector2(0,0)

func _unhandled_input(event):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT:
		return
	
	if event.is_pressed():
		initiate_targeting()
	elif not event.is_pressed():
		complete_targeting()
