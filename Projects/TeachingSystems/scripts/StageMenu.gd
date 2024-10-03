extends Node2D

@onready var menu_screen = %MenuScreen
@onready var color_rect = %ColorRect

func create_game(num: int):
	const GAME = preload("res://scenes/game.tscn")
	var new_game = GAME.instantiate()
	new_game.global_position = global_position
	add_child(new_game)
	if(new_game.has_method("read_stage_menu")):
		new_game.read_stage_menu(self)
	if(new_game.has_method("change_propedia")):
		new_game.change_propedia(num)
	menu_screen.hide()

func exit_game():
	menu_screen.show()
