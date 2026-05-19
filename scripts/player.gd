extends CharacterBody2D

const SPEED = 130.0
var dir = "down" 

@onready var animated_sprite = $AnimatedSprite2D
@export var inv: Bag

@onready var item_detector: Area2D = $ItemDetector
var is_picking_up: bool = false

func _ready() -> void:
	visible = false 
	await get_tree().process_frame
	
	if GameManager.target_spawn_id != "":
		var spawn_node = get_tree().current_scene.find_child(GameManager.target_spawn_id, true, false)
		if spawn_node:
			global_position = spawn_node.global_position
			GameManager.target_spawn_id = "" 
	if GameManager.use_saved_position:
		global_position = GameManager.player_saved_pos
		
	visible = true

func _physics_process(delta):
	# 2. HARD LOCK FOR DIALOGUE OR PICKUP ANIMATION
	if GameManager.is_dialogue_active or is_picking_up:
		velocity = Vector2.ZERO 
		move_and_slide() 
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	# 3. HANDLE THE "E" INPUT FOR PICKING UP ITEMS
	# We use is_action_just_pressed so mashing doesn't loop it infinitely
	if Input.is_action_just_pressed("interact"): # Assumes "E" or ui_accept
		if pickable():
			trigger_pickup_sequence()
			return

	# Horizontal axis
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_direction * SPEED
	
	# Input directions & Sprite Flipping
	if Input.is_action_pressed("move_right"):
		dir = "right"
	elif Input.is_action_pressed("move_left"):
		dir = "left"
	elif Input.is_action_pressed("move_down") and is_on_floor():
		dir = "down"
	elif Input.is_action_pressed("move_up") and is_on_floor():
		dir = "up"
		
	# Play movement animations
	if velocity.x != 0:
		animated_sprite.play("walk_" + dir)
	else:
		animated_sprite.play("idle_" + dir)
	
	move_and_slide()

#PICKUP SEQUENCE LOGIC
func trigger_pickup_sequence() -> void:
	# 1. FIND THE ITEM IMMEDIATELY before setting flags or stalling the frame!
	var target_item = get_overlapping_loot()
	
	if target_item == null:
		return # If there's no item, don't freeze the player at all!

	# Save the item's name right now while we know it exists safely
	var saved_name = target_item.item_data.name 

	is_picking_up = true
	velocity = Vector2.ZERO
	
	if dir == "left":
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

	animated_sprite.play("pickup")
	
	# Wait for your boy to bend down and finish the clip
	await animated_sprite.animation_finished
	
	animated_sprite.flip_h = false
	
	# 2. Collect it using our stored reference
	if target_item and target_item.has_method("collect"):
		target_item.collect(inv)
		
		# 3. Call your custom item detector scene to fire the sound and wood label!
		if item_detector and item_detector.has_method("play_pickup_effects"):
			item_detector.play_pickup_effects(saved_name)
	
	is_picking_up = false

# ITEM CHECKER
func pickable() -> bool:
	return get_overlapping_loot() != null
	
func get_overlapping_loot() -> GroundItem:
	var areas = item_detector.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("ingredients") and area is GroundItem:
			return area
	return null
