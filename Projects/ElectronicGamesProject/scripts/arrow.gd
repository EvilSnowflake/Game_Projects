extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2(1.0,1.0)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	rotation_degrees += 90
	
	var mousedist = position.distance_to(get_global_mouse_position())
	#scale = Vector2(1.0,pow(mousedist,(1.0/3)))
