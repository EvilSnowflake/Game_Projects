class_name MainMenu
extends Control

#@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton as Button
@onready var start_button = $StartButton as Button
#@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/ExitButton as Button
@export var startLevel = preload("res://scenes/game.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Started Main menu")
	start_button.button_down.connect(on_start_button_down)
	#exit_button.button_down.connect(on_exit_button_down)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print("i am in main menu")

func on_start_button_down() -> void:
	print("Pressed start")
	get_tree().change_scene_to_packed(startLevel)
	
func on_exit_button_down() -> void:
	get_tree().quit()
