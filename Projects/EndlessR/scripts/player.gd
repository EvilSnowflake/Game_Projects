extends CharacterBody2D


var playerRoads
@onready var player_road = $"../playerRoad"
var road = 0
var max = 1
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	playerRoads = []
	max = player_road.get_child_count() - 1
	for child in player_road.get_children():
		#print(child.position)
		playerRoads.append(child.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("moveLeft"):
		road -= 1
		
	elif Input.is_action_just_pressed("moveRight"):
		road += 1
		#animated_sprite.play("TurnRight")
	
		
	if Input.is_action_pressed("moveLeft"):
		animated_sprite.play("TurnLeft")
	elif Input.is_action_pressed("moveRight"):
		animated_sprite.play("TurnRight")
	else:
		animated_sprite.play("Idle")
	if road < 0:
		road = 0
	if road > max:
		road = max
	position = playerRoads[road]


	

