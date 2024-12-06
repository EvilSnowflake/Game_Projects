extends Area2D

#@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	self.body_entered.connect(on_col_body_entered)

func on_col_body_entered(_body : Node2D):
	get_tree().reload_current_scene()
