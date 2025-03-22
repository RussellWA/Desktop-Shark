extends Node2D

signal ground_level(pos)
@onready var shark = $SpriteArea/Shark

func _ready():
	shark_init_pos()

	var system_node = $SystemNode
	if system_node:
		system_node.call("SetupTransparentWindow")

func shark_init_pos():
	var screen_size = DisplayServer.screen_get_size(0)
	var taskbar_height = get_taskbar_height()
	
	var shark_size = shark.texture.get_size() * shark.scale
	
	var x_pos = (screen_size.x - shark_size.x) / 2
	var y_pos = screen_size.y - taskbar_height - shark_size.y
	shark.global_position = Vector2(x_pos, y_pos)
	
	ground_level.emit(y_pos)

func get_taskbar_height():
	var height = DisplayServer.screen_get_size().y - DisplayServer.screen_get_usable_rect().size.y
	return height
