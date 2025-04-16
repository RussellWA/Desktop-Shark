extends Control

@onready var shark := $SharkAnimated

signal pet_or_hit(is_pet: bool)

# Drag and Fling
var is_dragging := false
var drag_offset := Vector2()
var previous_mouse_position := Vector2()
var mouse_velocity := Vector2.ZERO

# Shark Movement
var direction := 1
@export var gravity := 2500
@export var air_friction := 0.98
@export var ground_friction := 0.85
var velocity := Vector2.ZERO
@export var speed := 200.0
var is_on_ground := true
var ground_y: int
var taskbar_height: int
var screen_height: int
 
# Shark states
enum State { IDLE, FLUNG, MOVING, PETHIT }
var current_state = State.IDLE

# Timer states
@onready var timer := $Timer
@onready var delay_timer := $DelayTimer
enum TimerState { RUNNING, WAITING }
var timer_state := TimerState.WAITING

# Petting
var is_pet: bool
var petting_count := 0
var petting_speed := 0
@onready var petting_timer := $PettingTimer

# Other
var rng := RandomNumberGenerator.new()

func _ready():
	timer.wait_time = 3
	timer.one_shot = true
	#timer.start()
	
	delay_timer.wait_time = 6
	delay_timer.one_shot = true
	delay_timer.start()
	
	petting_timer.wait_time = 1
	petting_timer.one_shot = true
	
	timer.timeout.connect(_on_timer_timeout)
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	petting_timer.timeout.connect(_on_petting_timer_timeout)

func _process(delta):
	
	if is_dragging and not is_on_ground:
		if not timer.is_stopped():
			timer.stop()
			#print("Timer stopped due to dragging and falling")

		elif not delay_timer.is_stopped():
			delay_timer.stop()
			#print("Delay Timer stopped due to dragging and falling")

	elif !is_dragging and timer.is_stopped() and is_on_ground:
		if not delay_timer.is_stopped(): 
			pass

		else: 
			timer_state = TimerState.WAITING
			delay_timer.start()
			#print("Delay timer started")
	
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
			if shark.is_hovered():
				is_dragging = true
				current_state = State.IDLE
				
				velocity = Vector2.ZERO  # Reset velocity while dragging
				mouse_velocity = Vector2.ZERO
				drag_offset = get_global_mouse_position() - global_position

		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if is_dragging:
				is_dragging = false
				# Apply fling velocity
				mouse_velocity = InputTracker.velocity
				velocity = mouse_velocity
				
				# velocity.x has to be > 0 for it to not stick when drag release
				if velocity.x == 0:
					velocity.x = 1
				current_state = State.FLUNG
		else:
			if is_dragging:
				mouse_velocity = InputTracker.velocity
				velocity = mouse_velocity
				
			# velocity.x has to be > 0 for it to not stick when drag release
			if velocity.x == 0:
					velocity.x = 1
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		var current_mouse_position = get_global_mouse_position()
		global_position = current_mouse_position - drag_offset
		mouse_velocity = InputTracker.velocity
		is_on_ground = false

func apply_physics(delta):
	velocity.y += gravity * delta
	velocity.x *= air_friction
	shark.global_position += velocity * delta
	
	var viewport_rect = get_viewport_rect()
	var left_edge = viewport_rect.position.x
	var right_edge = viewport_rect.position.x + viewport_rect.size.x
	
	# Clamp the position to the screen edges
	var shark_size = shark.get_sprite_size()
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
	
	var shark_width = (shark.get_sprite_texture()).get_width()
	shark.global_position.x += speed * direction * delta
	
	# Shark width needed so it doesnt go off the right edge
	if shark.global_position.x + shark_width >= right_edge:
		direction = -1 # Move left

	elif shark.global_position.x <= left_edge:
		direction = 1 # Move right

func _on_timer_timeout():
	if timer_state == TimerState.RUNNING:
		# Transition to waiting state
		#print("Timer completed. Entering wait state...")
		timer_state = TimerState.WAITING
		
		var duration = rng.randf_range(8,13)
		timer.wait_time = duration  # Set wait duration
		
		direction = rng.randi_range(0, 1) * 2 - 1
		timer.start()  # Start the wait phase
		#print("duration ", duration)
	
	elif timer_state == TimerState.WAITING:
		# Transition back to running state
		#print("Wait time completed. Restarting timer...")
		timer_state = TimerState.RUNNING
		
		var duration = rng.randf_range(2,5) 
		timer.wait_time = duration  # Set duration for running
		
		direction = get_direction()
		timer.start()  # Restart the timer
		#print("duration ", duration)

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

func check_interaction(velocity: Vector2):
	if velocity.length() >= petting_speed:
		petting_speed = velocity.length()
	petting_count += 1
	print("speed ", petting_speed)
	
	if petting_count == 1 and not is_dragging:
		current_state = State.PETHIT
		petting_timer.start()
	elif petting_count == 2 and not is_dragging:
		petting_timer.stop()
		if petting_speed > 1000:
			is_pet = false
		elif petting_speed > 0:
			is_pet = true
			
		print("speed final ", petting_speed)
		petting_count = 0
		petting_speed = 0
		pet_or_hit.emit(is_pet)

func _on_petting_timer_timeout():
	petting_count = 0;
	current_state = State.IDLE

func _on_main_pet_hit_interaction(mouse_velo: Vector2) -> void:
	if mouse_velo.y >= 0:
		print("pet or hit")
		pass
		#check_interaction(mouse_velo)

func _on_shark_animated_pet_or_hit_anim_done() -> void:
	current_state = State.IDLE
