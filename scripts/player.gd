extends CharacterBody2D

const SPEED = 130.0
var dir = "right" 

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	# Horizontal axis
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	
	# Velocity
	velocity.x = horizontal_direction * SPEED
	
	# Input directions
	if Input.is_action_pressed("move_right"):
		dir = "right"
	elif Input.is_action_pressed("move_left"):
		dir = "left"
	elif Input.is_action_pressed("move_down") and is_on_floor():
		dir = "down"
	elif Input.is_action_pressed("move_up") and is_on_floor():
		dir = "up"
		
	# Play animation
	if velocity.x != 0:
		animated_sprite.play("walk_" + dir)
	else:
		animated_sprite.play("idle_" + dir)
		

	move_and_slide()
