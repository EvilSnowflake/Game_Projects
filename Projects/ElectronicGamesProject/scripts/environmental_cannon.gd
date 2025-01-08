extends Node2D

@onready var projectile = load("res://scenes/projectile.tscn")
@onready var game = get_tree().current_scene
@onready var shoot_timer = $ShootTimer
@onready var animation_player = $AnimationPlayer
@onready var fire_source = $ProjectileNode

var bullet_scale: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	disable_and_hide_node()
	shoot_timer.timeout.connect(on_shoot_timer_timeout)
	shoot_timer.start()
	animation_player.play("Growing")
	animation_player.queue("Idle")


func on_shoot_timer_timeout():
	animation_player.play("Fire")
	animation_player.queue("Idle")
	var startingRot = rotation
	#var degrad = deg_to_rad(startingRot)
	var degrad  = deg_to_rad(rotation_degrees - 90)
	print("Cannon shot!")
	#shoot(3)
	
func shoot( projectileCollision):
	#var startingRot = rotation
	#print(startingRot)
	#var degrad  = deg_to_rad(startingRot) - 90
	#print(degrad)
	#var projInstance = projectile.instantiate()
	#projInstance.dir = startingRot
	#projInstance.spawnPos = position
	#projInstance.spawnRot = degrad
	#projInstance.zdex = z_index - 1
	#projInstance.coll = projectileCollision
	#projInstance.source_uncommon = true 
	#game.add_child.call_deferred(projInstance)
	
	var startingSpawnRotation = fire_source.rotation
	#fire_source.rotation_degrees = fire_source.rotation_degrees + 90
	var tilted_rot = fire_source.rotation_degrees + 90
	var spawnPosition = fire_source.global_position
	#var spawnRotation = fire_source.rotation
	
	var projInstance = projectile.instantiate()
	projInstance.dir = tilted_rot
	projInstance.spawnPos = spawnPosition
	projInstance.spawnRot = startingSpawnRotation
	projInstance.zdex = z_index - 1
	projInstance.coll = projectileCollision
	projInstance.scale_number = bullet_scale
	game.add_child.call_deferred(projInstance)
	projInstance.source_uncommon = true 
	#animation_player.play("Idle")

func disable_and_hide_node() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED # = Mode: Disabled
	hide()

func enable_and_show_node() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT # = Mode: Inherit
	show()
