extends CharacterBody2D

@export var SPEED = 150
@export var DAMAGE = 30

var dir : float
var spawnPos : Vector2
var spawnRot : float
var zdex : int
var beingGrabbed = false
var coll = 1

@onready var collision_shape = $CollisionShape

func _ready():
	#print("I spawn with rotation : " + str(dir))
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zdex
	collision_shape.set_collision_layer_value(coll,true)
	collision_shape.set_collision_mask_value(coll,true)

func _on_collision_shape_body_entered(body):
	if body.name == "Player":
		body.take_damage(DAMAGE)
		body.velocity = velocity * 2
	queue_free()

func _physics_process(_delta):
	#print(dir)
	#print(rotation)
	velocity = Vector2(0, -SPEED).rotated(dir)
	if !beingGrabbed :
		move_and_slide()

func stop_collision():
	collision_shape.set_collision_layer_value(1,false)
	collision_shape.set_collision_mask_value(1,false)
	
func get_grabbed(_body):
	#print("Got grabbed")
	beingGrabbed = true

func released():
	#print("Got released")
	queue_free()

func set_direction(_rotationd):
	#print("Setting rotation to : "+ str(rotationd))
	dir = 180


func _on_collision_shape_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	#print(" Hit area : " + area.name)
	if area.name == "NocArea":
		area.get_parent().take_damage(DAMAGE)
		queue_free()

func set_collision(number):
	collision_shape.set_collision_layer_value(number,true)
	collision_shape.set_collision_mask_value(number,true)

func _on_self_destruct_timer_timeout():
	print("Destoy proecjtile")
	queue_free()


func _on_debug_timer_timeout():
	print("The dir i have is: " + str(dir) + ", then the rotation i have is: " + str(rotation_degrees) + ", then the global rotation i have is: " + str(global_rotation) )
