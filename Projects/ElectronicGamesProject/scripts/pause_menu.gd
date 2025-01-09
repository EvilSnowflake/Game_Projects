extends Control

@onready var game = get_tree().get_root().get_node("Game")
@onready var main_menu = $MarginContainer/HBoxContainer/VBoxContainer/MainMenu
@onready var quit = $MarginContainer/HBoxContainer/VBoxContainer/Quit
@onready var resume = $MarginContainer/HBoxContainer/VBoxContainer/Resume
@onready var sound_menu = $MarginContainer/HBoxContainer/VBoxContainer/SoundMenu
@onready var check_button = $MarginContainer/HBoxContainer/CheckButton

@export var menuLevel = "res://scenes/start_menu.tscn"
@export var soundControlMenu : Control
@export var meshFilterEffect : MeshInstance2D

# Called when the node enters the scene tree for the first time.
func _ready():
	resume.button_down.connect(on_resume_button_down)
	main_menu.button_down.connect(on_main_menu_button_down)
	quit.button_down.connect(on_quit_button_down)
	sound_menu.button_down.connect(on_sound_menu_button_down)
	check_button.toggled.connect(on_check_button_toggled)

func on_main_menu_button_down():
	game.pauseMenu()
	get_tree().change_scene_to_file(menuLevel)

func on_resume_button_down():
	game.pauseMenu()

func on_quit_button_down():
	get_tree().quit()

func on_sound_menu_button_down():
	soundControlMenu.show()

func on_check_button_toggled(toggled_on: bool):
	if meshFilterEffect.visible:
		meshFilterEffect.hide()
	else:
		meshFilterEffect.show()
	
