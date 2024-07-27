extends CharacterBody2D


const NEAR = 70
const VERYNEAR = 5

@export var MAXHEALTH = 100
@export var SPEEDVALUE = 50
@export var SHOOTABILITY = false
@export var MAXDISTANCE = 0
@export var UNCOMMONENEMY = false
@export var spawnOnDeath : Node2D

var parasiteInside
var parasitePos
var player
var beingGrabbed = false
var attacking = false
var direction = -1
var startPositionX
var shooting = false
var becomeEnemy = false

@onready var noc_area = $NocArea
@onready var attack_timer = $AttackTimer
@export var health = 0
@onready var game = get_tree().current_scene
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var posess_timer = $PosessTimer
@onready var noc_collision_shape = $NocCollisionShape
@onready var grab = $Grab
@onready var sprite_2d = $Sprite2D
@onready var melee = $Melee

const PARASITE = preload("res://scenes/parasite.tscn")

@onready var projectile = load("res://scenes/projectile.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAXHEALTH
	startPositionX = global_position.x
	#print(startPositionX)
	#print(MAXDISTANCE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if(becomeEnemy):
		#print("The enemy is: " + str(position.x) + " and the player is: " +str(player.position.x))
		var distP = self.position.distance_to(player.position)
		if distP<=VERYNEAR:
			return
		#noc_collision_shape.look_at(player.global_position)
		#look_at(player.global_position)
		#look_at(player.position)
		if position.x < player.position.x:
			sprite_2d.flip_h = true
			direction = 1
			melee.rotation = 0
		elif position.x > player.position.x:
			sprite_2d.flip_h = false
			melee.rotation = -180
			direction = -1
		if attacking or distP<NEAR:
			return
		velocity = Vector2(direction*SPEEDVALUE,0)
		if (SHOOTABILITY):
			return
		if (player.global_position.x >= startPositionX + MAXDISTANCE or player.global_position.x <= startPositionX - MAXDISTANCE):
			return
		move_and_slide()
		#position = position.move_toward(Vector2(player.position.x,0), SPEED * _delta)
		


func _on_body_entered(body):
	print(body.name)
	if(body.name == "Player"):
		take_damage(25)
		body.velocity = -1 * body.velocity
	#if(body.name == "Player"):
	#	body.stickToObject(self)

func get_possesed(parasite, playerBody):
	print("Started getting possesed by parasite!")
	print(parasite)
	player = playerBody
	parasitePos = parasite.position
	parasiteInside = parasite
	posess_timer.start()
	#timer.start()
#This object needs to be able to transform into an enemy when a parasite enters


func _on_timer_timeout():
	#self.reparent(game)
	print("Make it unpowered")
	var exitedPar = PARASITE.instantiate()
	
	game.add_child(exitedPar)
	
	#exitedPar.nocNum = 1
	exitedPar.position = parasitePos
	#if(UNCOMMONENEMY):
	
	exitedPar.become_unpowered()

func take_damage(amount):
	health = clamp(health - amount,0,MAXHEALTH)
	print(health)
	
	#if i am an uncommon enemy there should be a change at 50% health which makes me more dangerous
	if( health <= MAXHEALTH/2 and UNCOMMONENEMY):
		attack_timer.wait_time = 1
	
	if(health <= 0):
		player.release_enemy()
		#player.velocity = Vector2(0,-100)
		attack_timer.stop()
		print("I died!!")
		var exitedPar = PARASITE.instantiate()
		#var remenantPar = PARASITE.instantiate()
		
		game.call_deferred("add_child",exitedPar)
		exitedPar.position = Vector2(position.x,parasitePos.y - 50)
		#exitedPar.reparent(game)
		noc_area.set_deferred("monitoring",false)
		noc_area.set_deferred("monitorable",false)
		set_collision_layer_value(3,false)
		set_collision_mask_value(3,false)
		grab.set_deferred("monitoring",false)
		grab.set_deferred("monitorable",false)
		#grab.monitoring = false
		#grab.monitorable = false
		animation_player.play("Dying")
		
		if(!UNCOMMONENEMY):
			var remenantPar = PARASITE.instantiate()
			game.call_deferred("add_child",remenantPar)
			remenantPar.position = Vector2(position.x,parasitePos.y - 50)
			remenantPar.become_unpowered()
			remenantPar.healthRestore = 35
			remenantPar.become_remenant()
			return
		exitedPar.become_unpowered()
		if(spawnOnDeath != null):
			spawnOnDeath.enable_and_show_node()
		


func _on_posess_timer_timeout():
	noc_area.monitorable = true
	noc_area.monitoring = true
	grab.monitoring = true
	grab.monitorable = true
	becomeEnemy = true
	#if !UNCOMMONENEMY:
	print("Got possesed")
	turn_enemy()
	attack_timer.start()

func turn_enemy():
	if health > 0 :
		animation_player.play("Enemying")

func _on_attack_timer_timeout():
	#depending on where the player is either throw projectile, attack directly or throw them off of yourself
	#Or we can make 2 types of enemies, once the walk up top the player and do a close attack
	#And ones that sit and throw projectiles
	noc_collision_shape.look_at(player.global_position)
	var startingRot = noc_collision_shape.rotation
	noc_collision_shape.rotation_degrees = noc_collision_shape.rotation_degrees + 90
	var distP = self.position.distance_to(player.position)
	var projSpawnPos = noc_collision_shape.global_position
	var projSpawnRot = noc_collision_shape.rotation
	#print("Attack, player is " + str(distP) + " amount away, we are at " + str(position) + " and they are at "+ str(player.position))
	#print("Rotation set is : " + str(startingRot))
	if beingGrabbed:
		player.take_damage(40)
		player.velocity = Vector2(0,-200)
		player.release_enemy()
		#animation_player.play("ShakeOff")
		return
	
	if(UNCOMMONENEMY and shooting):
		shoot(projSpawnPos, projSpawnRot, startingRot, 1)
		shooting = false
		return
	
	
	if(SHOOTABILITY):
		#print(projSpawnRot)
		shoot(projSpawnPos, projSpawnRot, startingRot, 1)
		return
	
	if( distP < NEAR):
		attacking = true
		animation_player.play("Attacking")
		shooting = true
	else:
		attacking = false
		

func shoot(spawnPosition, spawnRotation, startingSpawnRotation, projectileCollision):
	var projInstance = projectile.instantiate()
	projInstance.dir = spawnRotation
	projInstance.spawnPos = spawnPosition
	projInstance.spawnRot = startingSpawnRotation
	projInstance.zdex = z_index - 1
	projInstance.coll = projectileCollision
	game.add_child.call_deferred(projInstance)

func get_grabbed(_body):
	print("Got grabbed")
	beingGrabbed = true

func released():
	print("Got released")
	beingGrabbed = false

func _on_noc_area_body_entered(body):
	print(body.name)
	take_damage(25)
	body.velocity = -1 * body.velocity
	#if(body.name == "Player"):
	#	body.stickToObject(self)

func toggle_attacking():
	attacking = !attacking

