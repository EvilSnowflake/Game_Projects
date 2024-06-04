extends Area2D

func _on_body_entered(body):
	print("You Lost!")
	call_deferred("reloadLvl")

func reloadLvl():
	get_tree().reload_current_scene()
