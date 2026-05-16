extends CharacterBody2D

const SPEED = 130.0
var dir = "right" 

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	visible = false 
	await get_tree().process_frame
	
	if GameManager.target_spawn_id != "":
		# Look for the Marker2D that matches the name we saved
		var spawn_node = get_tree().current_scene.find_child(GameManager.target_spawn_id, true, false)
		
		if spawn_node:
			# Move the player to the marker's spot
			global_position = spawn_node.global_position
			# Clear the ID so it doesn't happen again
			GameManager.target_spawn_id = "" 
	if GameManager.use_saved_position:
		global_position = GameManager.player_saved_pos
		
	visible = true

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
	#elif Input.is_action_pressed("move_down") and is_on_floor():
		#dir = "down"
	elif Input.is_action_pressed("move_up") and is_on_floor():
		dir = "up"
		
	# Play animation
	if velocity.x != 0:
		animated_sprite.play("walk_" + dir)
	else:
		animated_sprite.play("idle_" + dir)
	
	move_and_slide()
		

#func teleport_to_marker():
	#print("Trying to find spawn: ", GameManager.target_spawn_id)
	#if GameManager.target_spawn_id == "":
		#return
		
	##Find all markers in the scene
	#var markers = get_tree().get_nodes_in_group("SpawnPoints")
	#for marker in markers:
		#if marker.name == GameManager.target_spawn_id:
			#global_position = marker.global_position
			#GameManager.target_spawn_id = "" 
			#break
		#
