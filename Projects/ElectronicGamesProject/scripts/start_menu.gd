extends Control

@onready var start_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/StartButton
@onready var exit_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ExitButton
@onready var sound_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SoundButton
@onready var mesh_instance_2d = $CanvasLayer/MeshInstance2D
@onready var button_sound_fx = $ButtonSoundFx
@onready var windowMesh : QuadMesh = load("res://Meshes/WindowMesh.tres")
@onready var wait_timer = $WaitTimer

#@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/ExitButton as Button
@export var startLevel = "res://scenes/game.tscn"
@export var soundControlMenu : Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("Started Main menu")
	mesh_instance_2d.mesh = windowMesh
	get_tree().get_root().size_changed.connect(resize)
	start_button.button_down.connect(on_start_button_down)
	exit_button.button_down.connect(on_exit_button_down)
	sound_button.button_down.connect(on_sound_menu_button_down)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func resize():
	#print(get_viewport().size)
	var vp_size = get_viewport().size
	windowMesh.size = vp_size
	windowMesh.center_offset.x = vp_size.x / 2
	windowMesh.center_offset.y = vp_size.y / 2

func on_start_button_down() -> void:
	#print("Pressed start")
	if(!wait_timer.is_stopped()):
		return
	button_sound_fx.play()
	wait_timer.start()
	await wait_timer.timeout
	get_tree().change_scene_to_file(startLevel)
	
func on_exit_button_down() -> void:
	if(!wait_timer.is_stopped()):
		return
	button_sound_fx.play()
	wait_timer.start()
	await wait_timer.timeout
	get_tree().quit()

func on_sound_menu_button_down():
	soundControlMenu.show()
