extends Control

var stage_menu
@export var stage_buttons: Array[Button] = []

func _ready():
	stage_menu = get_tree().get_root().get_node("Stage_Menu")
	for button in stage_buttons:
		button.pressed.connect(_on_stage_button_pressed.bind(button.text))

func _on_stage_button_pressed(stg_num: String):
	print("Starting stage "+ stg_num)
	if(stage_menu.has_method("create_game")):
		stage_menu.create_game(int(stg_num))
