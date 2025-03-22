extends Control

@onready var shark = $Shark

var is_dragging = false
var drag_offset = Vector2()

@export var gravity = 300
@export var max_fall_speed = 800
@export var bounce_factor = 0.2
var velocity = Vector2.ZERO

var ground_pos

func _process(delta):
	if !is_dragging:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
		
		shark.global_position += velocity * delta
		
		var ground_y = ground_pos
		if shark.global_position.y >= ground_y:
			shark.global_position.y = ground_y
			velocity.y = -velocity.y * bounce_factor

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if shark.get_rect().has_point(shark.to_local(mouse_pos)):
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
		else:
			is_dragging = false
			
	elif event is InputEventMouseMotion:
		if is_dragging:
			global_position = get_global_mouse_position() - drag_offset

func _on_main_ground_level(pos: Variant) -> void:
	ground_pos = pos
