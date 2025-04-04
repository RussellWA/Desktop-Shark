extends Control

@onready var shark = $Shark

# Drag and Fling
var is_dragging = false
var drag_offset: Vector2 = Vector2()
var previous_mouse_position: Vector2 = Vector2()
var mouse_velocity: Vector2 = Vector2.ZERO

# Shark Movement
var direction: int = 1
@export var gravity: int = 2500
@export var air_friction: float = 0.98
@export var ground_friction: float = 0.85
var velocity: Vector2 = Vector2.ZERO
@export var speed: float = 200.0
var is_on_ground: bool = true
var ground_y: int
var taskbar_height: int
var screen_height: int
 
# Shark states
enum State { IDLE, FLUNG, MOVING }
var current_state = State.IDLE

# Timer states
@onready var timer: Timer = $Timer
@onready var delay_timer: Timer = $DelayTimer
enum TimerState { RUNNING, WAITING }
var timer_state = TimerState.WAITING

# Petting
@export var pet_distance_threshold: float = 200.0  # Max distance for petting/hitting
@export var pet_speed_threshold: float = 200.0  # Speed below this = petting, above = hitting
var last_state: String = ""

var rng = RandomNumberGenerator.new()

func _ready():
	timer.wait_time = 3
	timer.one_shot = true
	#timer.start()
	
	delay_timer.wait_time = 6
	delay_timer.one_shot = true
	delay_timer.start()
	
	timer.timeout.connect(_on_timer_timeout)
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	

func _process(delta):
	
	var mouse_pos = get_global_mouse_position()
	var mouse_sprite_distance = abs(mouse_pos.y - shark.global_position.y)
	
	#var petting_velocity = (mouse_pos - last_mouse_pos).length() / delta
	var petting_velocity = Input.get_last_mouse_velocity()
	var isHover: bool = shark.get_rect().has_point(shark.to_local(mouse_pos))
	var new_state: String = "=="  # Default to no interaction
	
	#if mouse_sprite_distance <= pet_distance_threshold:
	if isHover:
		if petting_velocity.length() > pet_speed_threshold:
			new_state = "hit"
		else:
			new_state = "pet"
	
	if new_state != last_state:
		print(new_state)
		last_state = new_state  # Update last state
	
	if is_dragging and not is_on_ground:
		if not timer.is_stopped():
			timer.stop()
			print("Timer stopped due to dragging and falling")

		elif not delay_timer.is_stopped():
			delay_timer.stop()
			print("Delay Timer stopped due to dragging and falling")

	elif !is_dragging and timer.is_stopped() and is_on_ground:
		if not delay_timer.is_stopped(): 
			pass

		else: 
			timer_state = TimerState.WAITING
			delay_timer.start()
			print("Delay timer started")
	
	match current_state:
		State.IDLE:
			if is_on_ground and not is_dragging and timer_state == TimerState.RUNNING:
				apply_physics(delta)
				current_state = State.MOVING
		
		State.FLUNG:
			apply_physics(delta)
			if abs(velocity.x) < 0.1:
				current_state = State.IDLE
		
		State.MOVING:
			if timer_state == TimerState.WAITING or is_dragging:
				current_state = State.IDLE
			else:
				apply_physics(delta) 
				start_moving(delta)

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
				
				# velocity.x has to be > 0 for it to not stick when drag release
				if velocity.x == 0:
					velocity.x = 1
				current_state = State.FLUNG
		else:
			if is_dragging:
				velocity = mouse_velocity
				
			# velocity.x has to be > 0 for it to not stick when drag release
			if velocity.x == 0:
					velocity.x = 1
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		var current_mouse_position = get_global_mouse_position()
		global_position = current_mouse_position - drag_offset
		
		# Calculate mouse velocity (difference in mouse position per frame)
		mouse_velocity = (current_mouse_position - previous_mouse_position) / get_process_delta_time()
		previous_mouse_position = current_mouse_position
		is_on_ground = false

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

	#print("shark ", shark.global_position.y)
	
	if shark.global_position.y >= ground_y:
		is_on_ground = true
		shark.global_position.y = ground_y
		if abs(velocity.x) > 0.1:  # Small threshold to stop jittering
			velocity.x *= ground_friction  # Reduce horizontal velocity by 15% each frame

		else:
			velocity.x = 0

func start_moving(delta):
	var viewport_rect = get_viewport_rect()
	var left_edge = viewport_rect.position.x
	var right_edge = viewport_rect.position.x + viewport_rect.size.x
	
	var shark_width = shark.texture.get_width()
	shark.global_position.x += speed * direction * delta
	
	# Shark width needed so it doesnt go off the right edge
	if shark.global_position.x + shark_width >= right_edge:
		direction = -1 # Move left

	elif shark.global_position.x <= left_edge:
		direction = 1 # Move right

func _on_timer_timeout():
	if timer_state == TimerState.RUNNING:
		# Transition to waiting state
		print("Timer completed. Entering wait state...")
		timer_state = TimerState.WAITING
		
		var duration = rng.randf_range(8,13)
		timer.wait_time = duration  # Set wait duration
		
		direction = rng.randi_range(0, 1) * 2 - 1
		timer.start()  # Start the wait phase
		print("duration ", duration)
	
	elif timer_state == TimerState.WAITING:
		# Transition back to running state
		print("Wait time completed. Restarting timer...")
		timer_state = TimerState.RUNNING
		
		var duration = rng.randf_range(2,5) 
		timer.wait_time = duration  # Set duration for running
		
		direction = get_direction()
		timer.start()  # Restart the timer
		print("duration ", duration)

func _on_delay_timer_timeout():
	if timer.is_stopped() and is_on_ground and not is_dragging:
		timer_state = TimerState.RUNNING
		direction = get_direction()
		timer.start()
		print("Timer restarted after dragging stopped")

	else:
		timer_state = TimerState.RUNNING
		current_state = State.MOVING
		direction = get_direction()
		timer.start()
		print("Start Timer")

func _on_main_ground_level(pos: Variant, tb_height: int, sc_height: int) -> void:
	ground_y = pos
	taskbar_height = tb_height
	screen_height = sc_height

func get_direction():
	return rng.randi_range(0, 1) * 2 - 1

func _on_shark_gui_send_scale(size: int) -> void:
	var original_shark_size = shark.texture.get_size() * shark.scale
	var scale_factor = 0.1 # 10% scale change
	
	var window_height = get_viewport().get_visible_rect().size.y
	var taskbar_y = window_height - taskbar_height
	
	#print("before ", shark.global_position.y)
	if size == -1:
		shark.scale *= (1 - scale_factor)
	elif size == 1:
		shark.scale *= (1 + scale_factor)
	
	var new_shark_size = shark.texture.get_size() * shark.scale
	
	#print("new shark scale ", new_shark_size)
	
	var new_ground_y = screen_height - taskbar_height - new_shark_size.y
	
	ground_y = new_ground_y
	
	if current_state != State.FLUNG:
		shark.global_position.y = new_ground_y
	
