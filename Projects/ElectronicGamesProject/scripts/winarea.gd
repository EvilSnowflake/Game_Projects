extends Area2D

#@onready var collision_shape_2d = $CollisionShape2D
var _main_menu = "res://scenes/start_menu.tscn"

func _ready():
	self.body_entered.connect(on_col_body_entered)

func on_col_body_entered(_body : Node2D):
	#get_tree().call_deferred("reload_current_scene")
	get_tree().call_deferred("change_scene_to_file",_main_menu)
