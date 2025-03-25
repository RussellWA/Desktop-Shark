extends Control

@onready var shark = $Shark

var is_dragging = false
var drag_offset = Vector2()
var previous_mouse_position = Vector2()
var mouse_velocity = Vector2.ZERO

@export var gravity = 2500
@export var air_friction = 0.98
@export var ground_friction = 0.85
var velocity = Vector2.ZERO
var ground_y

@export var walk_speed = 200

var is_walking = false  # Whether the shark is walking (timed behavior)
var timer = 0.0         # Timer for walking behavior
var move_duration = 3.0  # Move for 3 seconds
var wait_duration = 2.0  # Wait for 2 seconds
var cycle_duration = move_duration + wait_duration

enum State { IDLE, FLUNG, WALKING }
var current_state = State.WALKING

var direction: int = 1  # 1 = moving right, -1 = moving left
@export var speed: float = 200.0

@onready var countdown_timer = $CountdownTimer

func _process(delta):
	match current_state:
		State.IDLE:
			print("idle")
			if !is_dragging:
				apply_physics(delta)
		
		State.FLUNG:
			print("flung")
			apply_physics(delta)
			if abs(velocity.x) < 0.1:
				current_state = State.IDLE
		
		State.WALKING:
			var left_edge = 10
			var right_edge = get_viewport_rect().size.x
			shark.global_position.x += speed * direction * delta
			if shark.global_position.x >= right_edge:
				direction = -1
			elif shark.global_position.x <= left_edge:
				direction = 1

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if shark.get_rect().has_point(shark.to_local(mouse_pos)):
				is_dragging = true
				current_state = State.IDLE
				
				velocity = Vector2.ZERO  # Reset velocity while dragging
				mouse_velocity = velocity
				
				drag_offset = get_global_mouse_position() - global_position
				previous_mouse_position = get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if is_dragging:
				is_dragging = false
				# Apply fling velocity
				velocity = mouse_velocity
				current_state = State.FLUNG
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

func apply_physics(delta):
	velocity.y += gravity * delta
	velocity.x *= air_friction
	shark.global_position += velocity * delta
	
	var viewport_rect = get_viewport_rect()
	var left_edge = viewport_rect.position.x
	var right_edge = viewport_rect.position.x + viewport_rect.size.x
	
	# Clamp the position to the screen edges
	var shark_size = shark.texture.get_size() * shark.scale
	shark.global_position.x = clamp(shark.global_position.x, left_edge, right_edge - shark_size.x)
	
	if shark.global_position.y >= ground_y:
		shark.global_position.y = ground_y
		if abs(velocity.x) > 0.1:  # Small threshold to stop jittering
			velocity.x *= ground_friction  # Reduce horizontal velocity by 15% each frame
		else:
			velocity.x = 0

func _on_main_ground_level(pos: Variant) -> void:
	ground_y = pos
