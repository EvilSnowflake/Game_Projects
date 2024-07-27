extends Control

@onready var game = get_tree().get_root().get_node("Game")
@onready var main_menu = $MarginContainer/VBoxContainer/MainMenu
@onready var quit = $MarginContainer/VBoxContainer/Quit
@onready var resume = $MarginContainer/VBoxContainer/Resume

@export var menuLevel = "res://scenes/start_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	resume.button_down.connect(on_resume_button_down)
	main_menu.button_down.connect(on_main_menu_button_down)
	quit.button_down.connect(on_quit_button_down)

func on_main_menu_button_down():
	get_tree().change_scene_to_file(menuLevel)

func on_resume_button_down():
	game.pauseMenu()

func on_quit_button_down():
	get_tree().quit()
