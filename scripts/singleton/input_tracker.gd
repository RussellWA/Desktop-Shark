extends Node

var previous_position := Vector2.ZERO
var velocity := Vector2.ZERO

func _ready():
	previous_position = get_viewport().get_mouse_position()

func _process(delta):
	var current = get_viewport().get_mouse_position()
	velocity = (current - previous_position) / delta
	previous_position = current
