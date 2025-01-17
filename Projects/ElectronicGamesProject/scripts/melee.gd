extends Area2D

@export var damage = 15


func _on_body_entered(body):
	if body.name == "Player":
		if !body.check_invulnerability():
			return
		#print("Hit player")
		body.take_damage(damage)
		set_deferred("monitoring",false)
		set_deferred("monitorable",false)
		body.velocity = Vector2(0,-200)
		#monitoring = false
		#monitorable = false
		#queue_free()

func enable_attacking():
	monitoring = true
	monitorable = true
	#print("I am enabled!")
func disable_attacking():
	monitoring = false
	monitorable = false
	#print("I am disabled!")
