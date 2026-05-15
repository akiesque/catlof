extends Camera2D

# Set this to the Y-pixel height where you want the camera fixed
@export var fixed_y_position: float = 0.0 

func _process(delta):
	# Force the camera to stay at a fixed vertical level
	global_position.y = fixed_y_position
