extends CharacterBody2D


const NEAR = 85
const VERYNEAR = 2
const friction = 5

@export var MAXHEALTH = 100
@export var SPEEDVALUE = 50
@export var UNCOMMONSPEEDVALUE = 250
@export var SHOOTABILITY = false
@export var MAXDISTANCE = 0
@export var UNCOMMONENEMY = false
@export var spawnOnDeath : Array[Node2D]
@export var dashLength = 200
@export var dashSpeed = 3
@export var direction = -1
@export var give_ability: Player.PlayerAbilities = Player.PlayerAbilities.NONE
@export var health = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*0.75
var parasiteInside
var parasitePos
var player
var player_target
var beingGrabbed = false
var attacking = false
var startPositionX
var startPositionY
var shooting = false
var becomeEnemy = false
var died = false
var dashing = false
var chasing = true
var shaking = false
var melee_word = "Melee"
var ranged_word = "Ranged"
var uncommon_word = "Uncommon"
var anim_word = ""
var fire_source

@onready var uncommon_melee = $Uncommon_Melee
@onready var uncommon_idle = $Uncommon_Idle
@onready var uncommon_hurt = $Uncommon_Hurt
@onready var ranged_idle = $Ranged_Idle
@onready var ranged_hurt = $Ranged_Hurt
@onready var melee_hurt = $Melee_Hurt
@onready var melee_attack = $Melee_Attack
@onready var melee_shakeout = $Melee_Shakeout
@onready var melee_walk = $Melee_Walk
@onready var noc_area = $NocArea
@onready var attack_timer = $AttackTimer
@onready var game = get_tree().current_scene
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var posess_timer = $PosessTimer
@onready var noc_collision_shape = $NocCollisionShape
@onready var projectile_node = $ProjectileNode
@onready var uncommon_projectile_node = $UncommonProjectileNode
@onready var grab = $Grab
@onready var sprite_2d = $Sprite2D
@onready var melee = $Melee
@onready var melee_uncommon = $MeleeUNCOMMON

const PARASITE = preload("res://scenes/parasite.tscn")

@onready var projectile = load("res://scenes/projectile.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAXHEALTH
	startPositionX = global_position.x
	startPositionY = global_position.y
	if(!SHOOTABILITY and !UNCOMMONENEMY):
		anim_word = melee_word
	elif(SHOOTABILITY and !UNCOMMONENEMY):
		anim_word = ranged_word
	else:
		anim_word = uncommon_word
		z_index = -1
		set_collision_layer_value(5,false)
		set_collision_mask_value(5,false)
	animation_player.play(anim_word+"_Idle")
	#print(startPositionX)
	#print(MAXDISTANCE)
	if(UNCOMMONENEMY):
		fire_source = uncommon_projectile_node
	else:
		fire_source = projectile_node


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if(died or !becomeEnemy):
		velocity.x = 0
		return
		
	if !is_on_floor_only() and !UNCOMMONENEMY:
		velocity.y += gravity * _delta
	else:
		velocity.y = 0
	fire_source.look_at(player_target.global_position)
	if UNCOMMONENEMY:
		if !attacking:
			position = position.move_toward(Vector2(startPositionX,startPositionY), UNCOMMONSPEEDVALUE * _delta)
			if !uncommon_idle.playing:
				uncommon_idle.play()
			return
		if(dashing and (position.x < startPositionX+(MAXDISTANCE*direction))):
			velocity = Vector2(direction*UNCOMMONSPEEDVALUE,0)
		elif(position.x >= startPositionX+(MAXDISTANCE*direction)):
			velocity.x = 0
			
			return
	move_and_slide()
	add_friction()
	if(UNCOMMONENEMY):
		return
	
	if(becomeEnemy and !SHOOTABILITY):
		if velocity.x == 0  and !dashing and !shaking:
			animation_player.play(anim_word + "_Possesed_Idle")
			melee_walk.stop()
			
		elif (velocity.x != 0 and !dashing):
			animation_player.play(anim_word + "_Possesed_Move")
			if !melee_walk.playing:
				melee_walk.play()
				
		if (player.global_position.x >= startPositionX + MAXDISTANCE or player.global_position.x <= startPositionX - MAXDISTANCE) and !dashing:
			chasing = false
		else:
			chasing = true
		#velocity.x = direction*dashLength*dashSpeed
		#print("The enemy is: " + str(position.x) + " and the player is: " +str(player.position.x))
		var _distP = position.distance_to(player.position)
		var distX = position.x - player.position.x
		if abs(distX)<=VERYNEAR:
			return
		if !chasing:
			position = position.move_toward(Vector2(startPositionX,startPositionY), SPEEDVALUE * _delta)
			return
		
		if attacking:
			return
			
		if !dashing:
			velocity = Vector2(direction*SPEEDVALUE,0)
		#position = position.move_toward(Vector2(player.position.x,0), SPEED * _delta)
	elif SHOOTABILITY:
		if anim_word == ranged_word and !ranged_idle.playing:
			ranged_idle.play()
		
	if position.x < player.position.x:
		sprite_2d.flip_h = true
		direction = 1
		#melee.rotation = 0
	elif position.x > player.position.x:
		sprite_2d.flip_h = false
		#melee.rotation = -180
		direction = -1
	

func add_friction():
	velocity.x = move_toward(velocity.x, 0, friction)

func _on_body_entered(body):
	#print(body.name)
	if(body.name == "Player"):
		take_damage(25)
		body.velocity = -1 * body.velocity
	#if(body.name == "Player"):
	#	body.stickToObject(self)

func get_possesed(parasite, playerBody):
	#print("Started getting possesed by parasite!")
	#print(parasite)
	player = playerBody
	#print(player.global_position)
	for i in range(player.get_child_count()):
		if(player.get_child(i).name != "Enemy_Target"):
			continue
		else:
			player_target = player.get_child(i)
			#print("There is a target")
			break
	if player_target == null:
		#print("There is not")
		player_target = player
	#print(player_target.global_position)
	parasitePos = parasite.position
	parasiteInside = parasite
	posess_timer.start()
	#timer.start()
#This object needs to be able to transform into an enemy when a parasite enters


func _on_timer_timeout():
	#self.reparent(game)
	#print("Make it unpowered")
	var exitedPar = PARASITE.instantiate()
	
	game.add_child(exitedPar)
	
	#exitedPar.nocNum = 1
	exitedPar.position = parasitePos
	#if(UNCOMMONENEMY):
	
	exitedPar.become_unpowered()

func take_damage(amount):
	health = clamp(health - amount,0,MAXHEALTH)
	#print(health)
	if anim_word == melee_word and !UNCOMMONENEMY:
		melee_walk.stop()
		melee_hurt.play()
	elif anim_word == ranged_word and !UNCOMMONENEMY:
		ranged_idle.stop()
		ranged_hurt.play()
	elif UNCOMMONENEMY:
		uncommon_idle.stop()
		uncommon_hurt.play()
	#if i am an uncommon enemy there should be a change at 50% health which makes me more dangerous
	if( health <= MAXHEALTH/2 and UNCOMMONENEMY):
		attack_timer.wait_time = 1
	
	if(health <= 0 and becomeEnemy):
		died = true
		player.release_enemy()
		#player.velocity = Vector2(0,-100)
		attack_timer.stop()
		#print("I died!!")
		var prevParent = self.get_parent()
		self.call_deferred("reparent",game)
		var exitedPar = PARASITE.instantiate()
		#var remenantPar = PARASITE.instantiate()
		
		game.call_deferred("add_child",exitedPar)
		exitedPar.position = Vector2(position.x,parasitePos.y - 50)
		exitedPar.nocsParent = prevParent
		
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
		
		if(spawnOnDeath != null):
			for spawn in spawnOnDeath:
				spawn.enable_and_show_node()
		if(!UNCOMMONENEMY):
			var remenantPar = PARASITE.instantiate()
			game.call_deferred("add_child",remenantPar)
			remenantPar.position = Vector2(position.x,parasitePos.y - 50)
			remenantPar.become_unpowered()
			remenantPar.healthRestore = 35
			remenantPar.become_remenant()
			return
		exitedPar.become_unpowered()
		exitedPar.assing_ability(give_ability)
		becomeEnemy = false
		


func _on_posess_timer_timeout():
	noc_area.monitorable = true
	noc_area.monitoring = true
	grab.monitoring = true
	grab.monitorable = true
	becomeEnemy = true
	#if !UNCOMMONENEMY:
	#print("Got possesed")
	turn_enemy()
	attack_timer.start()

func turn_enemy():
	if health > 0 :
		animation_player.play(anim_word + "_Possesed_Idle")

func _on_attack_timer_timeout():
	#depending on where the player is either throw projectile, attack directly or throw them off of yourself
	#Or we can make 2 types of enemies, once the walk up top the player and do a close attack
	#And ones that sit and throw projectiles
	#print("attack")
	#var startingRot = projectile_node.rotation
	#projectile_node.rotation_degrees = projectile_node.rotation_degrees + 90
	var distP = self.position.distance_to(player.position)
	#var projSpawnPos = projectile_node.global_position
	#var projSpawnRot = projectile_node.rotation
	#print("Attack, player is " + str(distP) + " amount away, we are at " + str(position) + " and they are at "+ str(player.position))
	#print("Rotation set is : " + str(startingRot))
	if beingGrabbed:
		player.take_damage(20)
		player.velocity = Vector2(0,-200)
		player.release_enemy()
		toggle_shaking()
		animation_player.play(anim_word + "_Possesed_ShakeOut")
		if anim_word == melee_word and !melee_shakeout.playing:
			melee_walk.stop()
			melee_shakeout.play()
		return
	
	if(UNCOMMONENEMY and shooting):
		animation_player.play(anim_word+"_Possesed_Attack")
		animation_player.queue(anim_word+"_Possesed_Idle")
		shooting = false
		uncommon_idle.stop()
		#uncommon_melee.play()
		return
	elif (UNCOMMONENEMY and !shooting):
		animation_player.play(anim_word + "_Possesed_Attack_Melee")
		animation_player.queue(anim_word+"_Possesed_Idle")
		attacking = true
		#dashing = true
		shooting = true
		uncommon_idle.stop()
		#uncommon_melee.play()
		return
		
	if(SHOOTABILITY):
		#print(projSpawnRot)
		#shoot(1)
		attack_timer.stop()
		animation_player.play(anim_word+"_Possesed_Attack")
		animation_player.queue(anim_word+"_Possesed_Idle")
		return
	
	
	if( distP < NEAR):
		dashing = true
		attacking = true
		animation_player.play(anim_word+"_Possesed_Attack")
		animation_player.queue(anim_word+"_Possesed_Idle")
		#velocity.y = -500
		velocity.x = direction*dashLength
		melee_walk.stop()
		melee_attack.play()
		
		shooting = true
		attack_timer.stop()
	else:
		attacking = false
		

func shoot(projectileCollision):
	var startingSpawnRotation = fire_source.rotation
	fire_source.rotation_degrees = fire_source.rotation_degrees + 90
	var spawnPosition = fire_source.global_position
	var spawnRotation = fire_source.rotation
	
	var projInstance = projectile.instantiate()
	projInstance.dir = spawnRotation
	projInstance.spawnPos = spawnPosition
	projInstance.spawnRot = startingSpawnRotation
	projInstance.zdex = z_index - 1
	projInstance.coll = projectileCollision
	game.add_child.call_deferred(projInstance)
	projInstance.source_uncommon = UNCOMMONENEMY 

func get_grabbed(_body):
	#print("Got grabbed")
	beingGrabbed = true

func released():
	#print("Got released")
	beingGrabbed = false

func _on_noc_area_body_entered(body):
	#print(body.name)
	take_damage(25)
	#if(body.name == "Player"):
	#	body.stickToObject(self)
	body.velocity = -1 * body.velocity

func toggle_attacking():
	attacking = !attacking

func toggle_dashing():
	dashing = !dashing

func toggle_shaking():
	shaking = !shaking

func stop_vel():
	velocity.x = 0
