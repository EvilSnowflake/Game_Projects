extends Node

@onready var point_label = %pointLabel
const TIRES = preload("res://scenes/tires.tscn")
const DESTROYZONE = preload("res://scenes/destroyzone.tscn")
@onready var timer = $Timer
@onready var player_road = $"../playerRoad"
@onready var road_animated_sprite = $"../AnimatedSprite2D"

var lastNum = 0
var max = 0
var enmyRoads = []


# Called when the node enters the scene tree for the first time.
func _ready():
	max = player_road.get_child_count() - 1 
	for child in player_road.get_children():
		#print(child.position)
		enmyRoads.append(child.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if((int(point_label.text)/100) < 1):
		timer.wait_time = 1 - (int(point_label.text)/100)
	road_animated_sprite.speed_scale = 1 + (int(point_label.text)/10)


func _on_timer_timeout():
	
	var createdTires = []
	for child in enmyRoads:
		var tire = TIRES.instantiate()
		tire.tireSpeed = int(point_label.text)
		createdTires.append(tire)
		
	
	#var v_instance2 = TIRES.instantiate()
	var i = randf_range(-3,3)
	print("Random value is " + str(i))
	print("Last random value is " + str(lastNum))
	
	var openRoad = lastNum + i
	print("Open road is " + str(openRoad))
	if openRoad < 0:
		openRoad = 0
	if openRoad > max:
		openRoad = max
	
	var dest = DESTROYZONE.instantiate()
	dest.pointSpeed = int(point_label.text)
	dest.position = enmyRoads[0]
	dest.position.y -= 60
	dest.pt_label = point_label
	for j in range(createdTires.size()):
		if j == int(openRoad):
			continue
		createdTires[j].position = enmyRoads[j]
		createdTires[j].position.y -= 60
		add_child(createdTires[j])
	add_child(dest)	
	lastNum = openRoad
	#if i < 0.3:
	#	v_instance1.position = road_2.position
	#	v_instance2.position = road_3.position
	#elif i < 0.6:
	#	v_instance1.position = road_1.position
	#	v_instance2.position = road_3.position
	#else:
	#	v_instance1.position = road_1.position
	#	v_instance2.position = road_2.position
	#add_child(v_instance1)
	#add_child(v_instance2)
