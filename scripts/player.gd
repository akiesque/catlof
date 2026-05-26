extends CharacterBody2D

const SPEED = 160.0
const SPRINT_SPEED = 220.0
var dir = "down" 

@onready var sfx_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var animated_sprite = $AnimatedSprite2D
@export var inv: Bag

@onready var item_detector: Area2D = $ItemDetector
var is_picking_up: bool = false

var sfx: AudioStream = null
const PICKUP_RUSTLE = preload("uid://dny55rl6kukhy")

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
	if get_tree().paused:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if GameManager.is_dialogue_active or is_picking_up:
		velocity = Vector2.ZERO 
		move_and_slide() 
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("interact"):
		if pickable():
			trigger_pickup_sequence()
			return
			
	# sprint anim
	var current_speed = SPEED
	if GameManager.sprint_unlock:
		if Input.is_action_pressed("sprint"): 
			current_speed = SPRINT_SPEED

	# Horizontal axis
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_direction * current_speed
	
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
	var target_item = get_overlapping_loot()
	
	if target_item == null:
		return 

	var saved_name = target_item.item_data.name 

	is_picking_up = true
	velocity = Vector2.ZERO
	
	if dir == "left":
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

	animated_sprite.play("pickup")
	sfx_player.stream = PICKUP_RUSTLE
	sfx_player.play()
	
	# Wait for your boy to bend down and finish the clip
	await animated_sprite.animation_finished
	
	animated_sprite.flip_h = false
	
	if target_item and target_item.has_method("collect"):
		target_item.collect(inv)
		
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
