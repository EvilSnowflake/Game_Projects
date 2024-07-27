extends Node2D

@onready var projectile = load("res://scenes/projectile.tscn")
@onready var game = get_tree().current_scene
@onready var shoot_timer = $ShootTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	disable_and_hide_node()
	shoot_timer.timeout.connect(on_shoot_timer_timeout)
	shoot_timer.start()


func on_shoot_timer_timeout():
	var startingRot = rotation
	#var degrad = deg_to_rad(startingRot)
	var degrad  = deg_to_rad(rotation_degrees - 90)
	print("Cannon shot!")
	shoot(position,startingRot,degrad,3)
	
func shoot(spawnPosition, spawnRotation, startingSpawnRotation, projectileCollision):
	var projInstance = projectile.instantiate()
	projInstance.dir = spawnRotation
	projInstance.spawnPos = spawnPosition
	projInstance.spawnRot = startingSpawnRotation
	projInstance.zdex = z_index - 1
	projInstance.coll = projectileCollision
	game.add_child.call_deferred(projInstance)

func disable_and_hide_node() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED # = Mode: Disabled
	hide()

func enable_and_show_node() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT # = Mode: Inherit
	show()
