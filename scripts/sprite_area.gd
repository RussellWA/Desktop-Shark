extends Control

@onready var shark = $Shark

var is_dragging = false
var drag_offset = Vector2()
var previous_mouse_position = Vector2()
var mouse_velocity = Vector2.ZERO

@export var gravity = 2500
@export var bounce_factor = 0.2
@export var air_friction = 0.98  # Simulate air resistance for horizontal motion
var velocity = Vector2.ZERO

var ground_pos

func _process(delta):
	if !is_dragging:
		velocity.y += gravity * delta
		
		velocity.x *= air_friction
		
		shark.global_position += velocity * delta
		
		# Get the viewport edges
		var viewport_rect = get_viewport_rect()
		var left_edge = viewport_rect.position.x
		var right_edge = viewport_rect.position.x + viewport_rect.size.x
		var top_edge = viewport_rect.position.y
		var bottom_edge = viewport_rect.position.y + viewport_rect.size.y
		
		# Get the size of the shark sprite
		var shark_size = shark.texture.get_size() * shark.scale
		
		# Clamp the position to the screen edges
		shark.global_position.x = clamp(shark.global_position.x, left_edge, right_edge - shark_size.x)
		#shark.global_position.y = clamp(shark.global_position.y, top_edge, bottom_edge)
		
		var ground_y = ground_pos
		if shark.global_position.y >= ground_y:
			shark.global_position.y = ground_y
			velocity.y = -velocity.y * bounce_factor
			if abs(velocity.x) > 0.1:  # Small threshold to stop jittering
				velocity.x *= 0.85  # Reduce horizontal velocity by 15% each frame
			else:
				velocity.x = 0
		
		#if shark.global_position.x <= left_edge or shark.global_position.x >= right_edge - shark_size.x:
			#velocity.y

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if shark.get_rect().has_point(shark.to_local(mouse_pos)):
				is_dragging = true
				velocity = Vector2.ZERO  # Reset velocity while dragging
				drag_offset = get_global_mouse_position() - global_position
				previous_mouse_position = get_global_mouse_position()
		else:
			if is_dragging:
				# Apply mouse velocity to the shark when releasing drag
				velocity = mouse_velocity
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		var current_mouse_position = get_global_mouse_position()
		global_position = current_mouse_position - drag_offset
		
		# Calculate mouse velocity (difference in mouse position per frame)
		mouse_velocity = (current_mouse_position - previous_mouse_position) / get_process_delta_time()
		previous_mouse_position = current_mouse_position

func _on_main_ground_level(pos: Variant) -> void:
	ground_pos = pos
