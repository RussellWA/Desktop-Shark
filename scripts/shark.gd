extends Sprite2D

# Movement variables
var speed = 100
var moving = false
signal timeout

# Timer for controlling walk and stop behavior
var move_timer: Timer

#func _ready():
	## Set up the timer for controlling movement
	#move_timer = Timer.new()
	#add_child(move_timer)
	#move_timer.wait_time = 3
	#move_timer.timeout.connect(_on_move_timer_timeout)
	#move_timer.start()
#
	#print("Pet initialized!")

#func _process(delta):
	#if moving:
		## Make the pet move left or right
		#position.x += speed * delta
		## Bounce if hitting the screen edges
		#var screen_size = DisplayServer.screen_get_size(0)
		#if position.x < 0 or position.x > screen_size.x - texture.get_size().x:
			#speed = -speed  # Reverse direction

# Timer callback to toggle movement
func _on_move_timer_timeout():
	moving = !moving
