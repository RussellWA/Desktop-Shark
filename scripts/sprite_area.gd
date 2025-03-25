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
var is_on_ground = true
var ground_y

@export var walk_speed = 200

# Shark states
enum State { IDLE, FLUNG, MOVING }
var current_state = State.MOVING

# Timer states
@onready var timer: Timer = $Timer
@onready var delay_timer: Timer = $DelayTimer
enum TimerState { RUNNING, WAITING }
var timer_state = TimerState.RUNNING

var direction: int = 1  # 1 = moving right, -1 = moving left
@export var speed: float = 200.0

var rng = RandomNumberGenerator.new()

func _ready():
	timer.wait_time = 3
	timer.one_shot = true
	timer.start()
	
	delay_timer.wait_time = 5
		
	timer.timeout.connect(_on_timer_timeout)
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	

func _process(delta):
	if is_dragging and not timer.is_stopped() and not is_on_ground:
		timer.stop()
		print("Timer stopped due to dragging and falling.")
	elif !is_dragging and timer.is_stopped() and is_on_ground:
		timer.start()
		print("Timer restarted after dragging stopped.")
		#delay_timer.start()
		#print("Delay Timer started after hitting ground.")
	
	match current_state:
		State.IDLE:
			if is_on_ground and not is_dragging and timer_state == TimerState.RUNNING:
				apply_physics(delta)
				current_state = State.MOVING
		
		State.FLUNG:
			apply_physics(delta)
			#print("this")
			if abs(velocity.x) < 0.1:
				#print("idle")
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
			print("clicked")
			var mouse_pos = get_global_mouse_position()
			if shark.get_rect().has_point(shark.to_local(mouse_pos)):
				print("start drag")
				is_dragging = true
				current_state = State.IDLE
				
				velocity = Vector2.ZERO  # Reset velocity while dragging
				mouse_velocity = velocity
				
				drag_offset = get_global_mouse_position() - global_position
				previous_mouse_position = get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if is_dragging:
				print('fling')
				is_dragging = false
				# Apply fling velocity
				velocity = mouse_velocity
				print(velocity)
				current_state = State.FLUNG
		else:
			if is_dragging:
				velocity = mouse_velocity
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		var current_mouse_position = get_global_mouse_position()
		global_position = current_mouse_position - drag_offset
		
		# Calculate mouse velocity (difference in mouse position per frame)
		mouse_velocity = (current_mouse_position - previous_mouse_position) / get_process_delta_time()
		previous_mouse_position = current_mouse_position
		
		is_on_ground = false

func apply_physics(delta):
	#print("apply physics")
	velocity.y += gravity * delta
	velocity.x *= air_friction
	shark.global_position += velocity * delta
	
	#print('y: ', velocity.y, ' | x: ', velocity.x, ' | pos: ', shark.global_position)
	
	var viewport_rect = get_viewport_rect()
	var left_edge = viewport_rect.position.x
	var right_edge = viewport_rect.position.x + viewport_rect.size.x
	
	# Clamp the position to the screen edges
	var shark_size = shark.texture.get_size() * shark.scale
	shark.global_position.x = clamp(shark.global_position.x, left_edge, right_edge - shark_size.x)
	
	if shark.global_position.y >= ground_y:
		#print("on ground")
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
	
	
	if shark.global_position.x + shark_width >= right_edge:
		direction = -1
	elif shark.global_position.x <= left_edge:
		direction = 1

func _on_timer_timeout():
	if timer_state == TimerState.RUNNING:
		# Transition to waiting state
		print("Timer completed. Entering wait state...")
		timer_state = TimerState.WAITING
		timer.wait_time = rng.randf_range(5,6)  # Set wait duration
		timer.start()  # Start the wait phase
	elif timer_state == TimerState.WAITING:
		# Transition back to running state
		print("Wait time completed. Restarting timer...")
		timer_state = TimerState.RUNNING
		timer.wait_time = rng.randf_range(3,4)  # Set duration for running
		timer.start()  # Restart the timer

func _on_delay_timer_timeout():
	print("Timer restarted after dragging stopped.")
	timer.start()

func _on_main_ground_level(pos: Variant) -> void:
	ground_y = pos
