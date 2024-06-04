extends CharacterBody2D
var tireSpeed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += (50 + tireSpeed) * delta 



func _on_timer_timeout():
	#print("deleted")
	queue_free()
