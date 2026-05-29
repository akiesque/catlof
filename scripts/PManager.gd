extends Node

# --- CONFIGURATION ---
const FRAME_WIDTH: int = 300
const FRAME_HEIGHT: int = 706

const SCOOT_OFFSET: float = 60.0

# Map your grid coordinates (Column, Row) per character sheet
const PORTRAIT_MAP: Dictionary = {
	"Casimir": {
		"sheet_path": "res://assets/sprites/dialogue/casimir.png",
		"expressions": {
			"c_default": Vector2(0, 0),
			"c_neutral": Vector2(1, 0),
			"c_smile": Vector2(2, 0),
			"c_conf": Vector2(0, 1),
			"c_teary": Vector2(1, 1),
			"c_angry": Vector2(2, 1),
			"c_happy": Vector2(0, 2),
			"c_flushed": Vector2(1, 2),
			"c_shocked": Vector2(2, 2),
		}
	},
	"Vivienne": {
		"sheet_path":  "res://assets/sprites/dialogue/m_neutral.png",
		"expressions": {
			"m_neutral": Vector2(0, 0),
		}
	},
	"Heinester": {
		"sheet_path":  "res://assets/sprites/dialogue/heinester.png",
		"expressions": {
			"h_neutral": Vector2(0, 0),
			"h_happy ": Vector2(0, 1),
			"h_frown": Vector2(0, 2),
			"h_shock": Vector2(1, 0),
			"h_conf": Vector2(1, 1),
			"h_mad": Vector2(1, 2),
			"h_smile": Vector2(2, 0),
			"h_sparkle": Vector2(2, 1),
			"h_flustered": Vector2(2, 2),
			
		}
	},
	#"Belomere": {
		#"sheet_path":  "res://assets/sprites/dialogue/happy.png",
		#"expressions": {
			#"b_neutral": Vector2(0, 0),
		#}
	#},
}

# --- STATE & POSITION NODES ---
var pos_A = null
var pos_B = null
var pos_C = null
var pos_D = null

var slot_occupation: Dictionary = {
	"CharacterA": "",
	"CharacterB": "",
	"CharacterC": "",
	"CharacterD": ""
}

const TWEEN_DURATION: float = 0.35
const DIM_COLOR: Color = Color(0.4, 0.4, 0.5, 1.0) 
const LIT_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0) 

## Your Main UI Scene will call this to hand over its TextureRect references safely!
func register_positions(node_a: TextureRect, node_b: TextureRect, node_c: TextureRect, node_d: TextureRect) -> void:
	pos_A = node_a
	pos_B = node_b
	pos_C = node_c
	pos_D = node_d
	
	for node in [pos_A, pos_B, pos_C, pos_D]:
		if node:
			node.set_meta("start_x", node.position.x)
			node.set_meta("start_y", node.position.y) # Fixed: Storing start_y for clean drop-down exits
			node.hide()

func _get_node_from_string(slot_name: String) -> TextureRect:
	match slot_name:
		"CharacterA": return pos_A
		"CharacterB": return pos_B
		"CharacterC": return pos_C
		"CharacterD": return pos_D
	return null

# --- PUBLIC FUNCTIONS ---

func show(character_name: String, expression: String, position_slot: String) -> void:
	var target_node: TextureRect = _get_node_from_string(position_slot)
	
	if target_node == null:
		push_error("PManager: Invalid position name given: " + position_slot)
		return
		
	if not PORTRAIT_MAP.has(character_name) or not PORTRAIT_MAP[character_name]["expressions"].has(expression):
		push_error("PManager: Expression '%s' not found for %s" % [expression, character_name])
		return

	var char_data = PORTRAIT_MAP[character_name]
	var grid_pos: Vector2 = char_data["expressions"][expression]
	
	var texture_sheet = load(char_data["sheet_path"])
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = texture_sheet
	atlas_tex.region = Rect2(grid_pos.x * FRAME_WIDTH, grid_pos.y * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
	target_node.texture = atlas_tex

	# Layering: Bring active speaker to front on EVERY line
	target_node.move_to_front()

	var is_new_to_slot = slot_occupation[position_slot] != character_name
	if is_new_to_slot:
		slot_occupation[position_slot] = character_name
		var base_x = target_node.get_meta("start_x", target_node.position.x)
		var entry_offset = _get_scoot_modifier(position_slot)
		
		var slide_direction: float = -30.0
		if position_slot == "CharacterC" or position_slot == "CharacterD":
			slide_direction = 30.0
		
		# Set entrance slide position
		target_node.position.x = (base_x + entry_offset) + slide_direction 
		target_node.modulate = Color(1, 1, 1, 0)
		target_node.show()

	# Process layout, shading, and dynamic scooting adjustments for everyone
	_update_character_tweens(position_slot)

func hide(character_name: String) -> void:
	for slot in slot_occupation.keys():
		if slot_occupation[slot] == character_name:
			slot_occupation[slot] = ""
			
			var node: TextureRect = _get_node_from_string(slot)
			if node:
				var target_y = node.get_meta("start_y", node.position.y) + 30
				var tween = create_tween().set_parallel(true)
				tween.tween_property(node, "position:y", target_y, TWEEN_DURATION)
				tween.tween_property(node, "modulate:a", 0.0, TWEEN_DURATION)
				tween.chain().tween_callback(_hide.bind(node))
			
			# Let remaining characters slide back if a blocking layout element vanishes
			_update_character_tweens("")
			break

func _hide(node: TextureRect) -> void:
	node.hide()
	if node.has_meta("start_y"):
		node.position.y = node.get_meta("start_y")

func hide_all() -> void:
	for slot in slot_occupation.keys():
		if slot_occupation[slot] != "":
			var char_name = slot_occupation[slot]
			hide(char_name)

# --- INTERNAL SYSTEM HELPERS ---

## Calculates if crowded outer layout spots (B & D) force A or C to move over
func _get_scoot_modifier(slot_name: String) -> float:
	# If B is active, push A leftward (-x)
	if slot_name == "CharacterA" and slot_occupation["CharacterB"] != "":
		return -SCOOT_OFFSET
	# If D is active, push C rightward (+x)
	if slot_name == "CharacterC" and slot_occupation["CharacterD"] != "":
		return SCOOT_OFFSET
	return 0.0

## Unified loop handling position shifts and focus tints smoothly
func _update_character_tweens(speaking_slot: String) -> void:
	if slot_occupation.values().all(func(char_name): return char_name == ""):
		return
		
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	for slot in slot_occupation.keys():
		if slot_occupation[slot] == "": 
			continue
			
		var node: TextureRect = _get_node_from_string(slot)
		if not node: continue
		
		var base_x = node.get_meta("start_x", node.position.x)
		var scoot_modifier = _get_scoot_modifier(slot)
		var final_target_x = base_x + scoot_modifier
		
		if slot == speaking_slot:
			tween.tween_property(node, "position:x", final_target_x, TWEEN_DURATION)
			tween.tween_property(node, "modulate", LIT_COLOR, TWEEN_DURATION)
		else:
			# Minor backstep depth illusion for out-of-focus elements
			var focus_backstep = 15.0 if (slot == "CharacterA" or slot == "CharacterB") else -15.0
			tween.tween_property(node, "position:x", final_target_x + focus_backstep, TWEEN_DURATION)
			tween.tween_property(node, "modulate", DIM_COLOR, TWEEN_DURATION)


## Usage: do PManager.bounce("CharacterA")
func bounce(position_slot: String) -> void:
	var target_node: TextureRect = _get_node_from_string(position_slot)
	if target_node == null or not target_node.visible:
		return
		
	# Grab the current position they are resting at (including scoot modifiers)
	var current_y = target_node.position.y
	var jump_height = 25.0 # How high they hop up in pixels
	
	# Create a quick sequential tween for the up-and-down motion
	var bounce_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Phase 1: Hop up elegantly
	bounce_tween.tween_property(target_node, "position:y", current_y - jump_height, 0.12)
	# Phase 2: Snap back down cleanly with a tiny gravity ease-in
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(target_node, "position:y", current_y, 0.12)


## Usage: do PManager.shake("CharacterA")
func shake(position_slot: String) -> void:
	var target_node: TextureRect = _get_node_from_string(position_slot)
	if target_node == null or not target_node.visible:
		return
		
	var original_x = target_node.position.x
	var shake_intensity = 12.0 # How violent the shake is in pixels
	var shake_speed = 0.04     # Timing of each vibration back-and-forth
	
	var shake_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	
	# Rapidly oscillate their X coordinate back and forth
	shake_tween.tween_property(target_node, "position:x", original_x - shake_intensity, shake_speed)
	shake_tween.tween_property(target_node, "position:x", original_x + shake_intensity, shake_speed)
	shake_tween.tween_property(target_node, "position:x", original_x - (shake_intensity * 0.6), shake_speed)
	shake_tween.tween_property(target_node, "position:x", original_x + (shake_intensity * 0.6), shake_speed)
	# Return perfectly back to home position
	shake_tween.tween_property(target_node, "position:x", original_x, shake_speed)
