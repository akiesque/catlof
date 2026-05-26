extends Node2D

@onready var interact_label: TextureButton = $InteractRange/CollisionShape2D/interact_label
@onready var bounce: AnimationPlayer = $InteractRange/CollisionShape2D/interact_label/Bounce

var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			var target = current_interactions[0]
			
			if "needs_up_input" in target and target.needs_up_input:
				if owner.dir != "up":
					return 
					
			can_interact = false
			interact_label.hide()
			await target.interact.call()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		var target = current_interactions[0]
		
		var is_facing_wrong = false
		if "needs_up_input" in target and target.needs_up_input:
			if owner.dir != "up":
				is_facing_wrong = true
		
		if target.is_interactable and not is_facing_wrong:
			# Check if the target explicitly wants to hide its UI
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
	
func _sort_by_nearest(area1, area2):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist


func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
