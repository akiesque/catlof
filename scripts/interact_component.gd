extends Node2D

@onready var interact_label: TextureButton = $InteractRange/CollisionShape2D/interact_label
@onready var bounce: AnimationPlayer = $InteractRange/CollisionShape2D/interact_label/Bounce

var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			var target = current_interactions[0]
			
			# Check if we should block interaction based on orientation
			if is_player_facing_wrong(target):
				return 
					
			can_interact = false
			interact_label.hide()
			await target.interact.call()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		var target = current_interactions[0]
		
		# Evaluate if the player is facing the wrong way for this specific object
		var is_facing_wrong = is_player_facing_wrong(target)
		
		if target.is_interactable and not is_facing_wrong:
			if "show_ui" in target and not target.show_ui:
				interact_label.visible = false
				bounce.stop()
			else:
				interact_label.visible = true
				if bounce.current_animation != "floating":
					bounce.play("floating")
		else:
			interact_label.visible = false
			bounce.stop()
	else:
		interact_label.visible = false
		bounce.stop()

## Helper function to determine if the player is oriented incorrectly for the target
func is_player_facing_wrong(target: Area2D) -> bool:
	# 1. Handle our upgraded Enum-based doors/stairs
	if "trigger_mode" in target:
		if target.trigger_mode == 2:
			return true
		# Must face UP
		if target.trigger_mode == 0 and owner.dir != "up": 
			return true
		# Must face DOWN
		if target.trigger_mode == 1 and owner.dir != "down":
			return true
			
	# 2. Backward compatibility for legacy objects still using the old boolean
	if "needs_up_input" in target and target.needs_up_input:
		if owner.dir != "up":
			return true
			
	return false
	
func _sort_by_nearest(area1, area2):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist


func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)
	# Look at the parent node of the interact zone (Heine)
	var npc = area.get_parent()
	if npc.has_method("show_tag"):
		npc.show_tag()


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
	var npc = area.get_parent()
	if npc.has_method("hide_tag"):
		npc.hide_tag()
