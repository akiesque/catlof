extends Node

# --- CONFIGURATION ---
const FRAME_WIDTH: int = 300
const FRAME_HEIGHT: int = 450

# Map your grid coordinates (Column, Row) per character sheet
const PORTRAIT_MAP: Dictionary = {
	"Casimir": {
		"sheet_path": "res://assets/sprites/dialogue/happy.png",
		"expressions": {
			"c_happy": Vector2(0, 0),
		}
	},
	"Vivienne": {
		"sheet_path":  "res://assets/sprites/dialogue/m_neutral.png",
		"expressions": {
			"m_neutral": Vector2(0, 0),
			#"c_shocked": Vector2(1, 0)
		}
	}
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

	var is_new_to_slot = slot_occupation[position_slot] != character_name
	if is_new_to_slot:
		slot_occupation[position_slot] = character_name
		var start_x = target_node.get_meta("start_x", target_node.position.x)
		target_node.position.x = start_x - 30 
		target_node.modulate = Color(1, 1, 1, 0)
		target_node.show()

	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	for slot in slot_occupation.keys():
		if slot_occupation[slot] == "": 
			continue
			
		var node: TextureRect = _get_node_from_string(slot)
		if not node: continue
		var base_x = node.get_meta("start_x", node.position.x)
		
		if slot == position_slot:
			tween.tween_property(node, "position:x", base_x, TWEEN_DURATION)
			tween.tween_property(node, "modulate", LIT_COLOR, TWEEN_DURATION)
		else:
			tween.tween_property(node, "position:x", base_x + 15, TWEEN_DURATION)
			tween.tween_property(node, "modulate", DIM_COLOR, TWEEN_DURATION)

func hide(character_name: String) -> void:
	for slot in slot_occupation.keys():
		if slot_occupation[slot] == character_name:
			slot_occupation[slot] = ""
			
			var node: TextureRect = _get_node_from_string(slot)
			if node:
				var target_x = node.get_meta("start_x", node.position.x) - 30
				var tween = create_tween().set_parallel(true)
				tween.tween_property(node, "position:x", target_x, TWEEN_DURATION)
				tween.tween_property(node, "modulate:a", 0.0, TWEEN_DURATION)
				tween.chain().perform(_hide, [node])
			break

func _hide(node: TextureRect) -> void:
	node.hide()

func hide_all() -> void:
	for slot in slot_occupation.keys():
		if slot_occupation[slot] != "":
			var char_name = slot_occupation[slot]
			hide(char_name)
