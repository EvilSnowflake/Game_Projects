extends Area2D

var pt_label
var pointSpeed = 1

func _process(delta):
	position.y += (50 + pointSpeed) * delta 


func _on_body_entered(body):
	#print("Got Point")
	
	pt_label.text = str(int(pt_label.text) + 1)
	#body.queue_free()


func _on_collision_shape_2d_ready():
	pass
