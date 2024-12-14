extends Node2D

@onready var pause_menu = %PauseMenu
@onready var mesh_instance_2d = $UserInterface/MeshInstance2D
@onready var parallax_background = $ParallaxBackground

var paused = false
var gameFrozen = false
var currbackgroundNum = 1
var nextbackgroundNum = 1

@onready var windowMesh : QuadMesh = load("res://Meshes/WindowMesh.tres")

@export var transition_areas: Array[Area2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#chaning_window_mesh = WINDOW_MESH.instantiate()
	mesh_instance_2d.mesh = windowMesh
	get_tree().get_root().size_changed.connect(resize)
	for trans_area in transition_areas:
		var areaNum = trans_area.name.substr(trans_area.name.length()-1,1).to_int()
		print(areaNum)
		trans_area.body_entered.connect(_on_body_enter_transition_area.bind(areaNum))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(get_viewport().size)
	#WINDOW_MESH.size = get_viewport().size
	if Input.is_action_just_pressed("Escape") and !gameFrozen:
		pauseMenu()

func resize():
	print(get_viewport().size)
	var vp_size = get_viewport().size
	windowMesh.size = vp_size
	windowMesh.center_offset.x = vp_size.x / 2
	windowMesh.center_offset.y = vp_size.y / 2

func _on_body_enter_transition_area(body : Node2D, area_num: int):
	nextbackgroundNum = area_num
	if(nextbackgroundNum == currbackgroundNum):
		return
	for i in range(parallax_background.get_child_count()):
		if(parallax_background.get_child(i).get_child_count() == 2):
			var animator_child : AnimationPlayer = parallax_background.get_child(i).get_child(1)
			animator_child.play("Place_"+str(currbackgroundNum)+"_"+str(nextbackgroundNum))
	currbackgroundNum = nextbackgroundNum


func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
