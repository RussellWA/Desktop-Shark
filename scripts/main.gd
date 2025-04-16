extends Node2D

signal pet_hit_interaction(mouse_velo: Vector2)
signal ground_level(pos, tb_height, sc_height)

@onready var shark = $SpriteArea/SharkAnimated
var was_hovering_last_frame = false

func _ready():
	shark_init_pos()
	set_process_input(true)

	var system_node = $SystemNode
	if system_node:
		system_node.call("SetupTransparentWindow")

func _process(delta):
	var is_hovering_now = shark.is_hovered()
	if is_hovering_now and not was_hovering_last_frame:
		pet_hit_interaction.emit(InputTracker.velocity)
	was_hovering_last_frame = is_hovering_now

func shark_init_pos():
	var screen_size = DisplayServer.screen_get_size(0)
	var taskbar_height = get_taskbar_height()
	
	var shark_size = shark.get_sprite_size()
	
	var x_pos = (screen_size.x - shark_size.x) / 2
	var y_pos = screen_size.y - taskbar_height - shark_size.y
	shark.global_position = Vector2(x_pos, y_pos)
	
	ground_level.emit(y_pos, taskbar_height, screen_size.y)

func get_taskbar_height():
	var height = DisplayServer.screen_get_size().y - DisplayServer.screen_get_usable_rect().size.y
	return height
