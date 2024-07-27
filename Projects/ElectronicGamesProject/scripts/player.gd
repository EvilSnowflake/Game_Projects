extends CharacterBody2D

@onready var float_timer = $FloatTimer
@onready var grab_area = $GrabArea
@onready var tick_timer = $TickTimer
@onready var coyote_timer = $CoyoteTimer
@onready var invulnerability_timer = $InvulnerabilityTimer
@onready var projectile = load("res://scenes/projectile.tscn")
#@onready var game = get_tree().get_root().get_node("Game")
@onready var game = get_tree().current_scene
#@onready var health_label = $"../UserInterface/EnergyPanel/MarginContainer/VBoxContainer/HBoxContainer/HealthLabel"
@onready var health_label = %HealthLabel
@onready var die_timer = $DieTimer


const SPEED = 200.0
const JUMP_VELOCITY = -200.0
const acc = 20
const friction = 50
const wall_jump_pushbck = 100
const velocity_mult = 3
const ARROW = preload("res://scenes/arrow.tscn")

const MAXJUMPS = 1

const MAXSLINGS = 1
const BIGACC = 400
const NEAR = 20 
const MAXHEALTH = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*0.75
var tempAr
var curInput = false
var grabbing = false
var startCur = Vector2()
var maxClam = Vector2(200,350)
var minClam = Vector2(-200,-350)
var motion = false
var numOfJumps = 1
var numOfGrabs = 1
var numOfSlings = 1
var objectSticked
var height_sticked = 0
var is_wall_sticking = false
var game_frozen = false
var moveTo
var was_on_floor = false
var vulnerable = true
var MAXGRABS = 0
@export var health = 75

func _ready():
	die_timer.timeout.connect(on_dietimer_timeout)
	health_label.text = str(health)
	#print(health)

func _physics_process(delta):
	if(moveTo == null):
		var direction = Input.get_axis("MoveLeft", "MoveRight")
		if direction:
			#print(velocity.x)
			#velocity.x = direction*SPEED
			accelerate(direction)
		elif !direction and !motion:
			add_friction()
		jump(delta)
		was_on_floor = is_on_floor()
		move_and_slide()
		if(was_on_floor && !is_on_floor()):
			coyote_timer.start()
		stayDuringStick()
		wall_stick(delta)
		grab()
		check_ground()
	else:
		move_to_position(moveTo,delta)
	#if is_on_wall():
	#	velocity.y = 0
	#	print("On wall")
		
	#--------Default Lines ------
	# Add the gravity.
	#var direction = Input.get_axis("MoveLeft", "MoveRight")
	#if !curInput:
	#	
	#	if direction:
	#		print(velocity.x)
	#		accelerate(direction)
	#	else:
	#		add_friction()
	# Handle jump.
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	
	#--------Default Lines ------
	#for i in get_slide_collision_count():
	#	var collision = get_slide_collision(i)
	#	print("I collided with",collision.get_collider().name)
	#At first the player should move a little slow and difficult
	# main way to move will be slinging from floor or walls towards enemies 1 time
	# they will also be able to sling from enemy to enemy indefinetly,
	# but can also stick to walls if holding in the direction of the wall
	# otherwise they will slide down the wall
	sling()
	
	#Also if close to a target they can attach to start damaging it
	# or sling towards the head part to atttempt to finish it immediately
	
func accelerate(direction):
	#velocity = velocity.move_toward(SPEED * direction, acc)
	#velocity.x = (velocity.x + acc*direction)
	#velocity.x = velocity.limit_length(SPEED).x
	#velocity.x = direction*SPEED
	velocity.x = move_toward(velocity.x, SPEED*direction, acc)

func add_friction():
	velocity.x = move_toward(velocity.x, 0, friction)

func check_ground():
	if is_on_floor() or is_on_wall():
		numOfGrabs = MAXGRABS
		numOfJumps = MAXJUMPS
		numOfSlings = MAXSLINGS

func jump(delta):
	
	if(!is_wall_sticking):
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("Space") and (is_on_floor() or is_on_wall() or !coyote_timer.is_stopped()):
		release_enemy()
		
		tick_timer.stop()
		if numOfJumps > 0:
			numOfJumps -= 1
			numOfSlings -= 1
			velocity.y = JUMP_VELOCITY
		if is_on_wall() and Input.is_action_pressed("MoveRight"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -wall_jump_pushbck
		if is_on_wall() and Input.is_action_pressed("MoveLeft"):
			velocity.y = JUMP_VELOCITY
			velocity.x = wall_jump_pushbck
	#elif Input.is_action_just_pressed("Space") and is_on_wall():
	#	velocity.x = JUMP_VELOCITY

func wall_stick(_delta):
	if is_on_wall_only():
		if Input.is_action_pressed("MoveLeft") or Input.is_action_pressed("MoveRight"):
			is_wall_sticking = true
		else:
			is_wall_sticking = false
	else:
		is_wall_sticking = false
	
	if is_wall_sticking:
		velocity.y = move_toward(velocity.y, 0, friction)
		#velocity.y = 0

func sling():
	#print(numOfSlings)
	#print(numOfJumps)
	if game.paused :
		return
	if numOfSlings > 0 and (is_on_floor() or is_on_wall() or !coyote_timer.is_stopped() or objectSticked != null or curInput):
		if Input.is_action_just_pressed("MouseLeftClick"):
			set_collision_layer_value(2,true)
			set_collision_mask_value(2,true)
			freeze_time()
			tempAr = createArrow()
			curInput = true
			velocity.x = 0
			startCur = get_global_mouse_position()
			print(get_global_mouse_position())
			
		elif Input.is_action_just_released("MouseLeftClick") and curInput:
			#if(objectSticked):
			tempAr.rotation_degrees -= 180
			var flippedRotation = tempAr.rotation
			tempAr.rotation_degrees -= 90
			shoot(position,flippedRotation,tempAr.rotation,3)
			#print("Rotation set is : " + str(tempAr.rotation_degrees))
			unfreeze_time()
			numOfSlings -=1
			numOfJumps -=1
			release_enemy()
			tick_timer.stop()
			#if tempAr:
			
			tempAr.queue_free()
			#var pushPower = startCur.distance_to(get_global_mouse_position())
			velocity = (Vector2((get_global_mouse_position().x - startCur.x)*velocity_mult,
			(get_global_mouse_position().y - startCur.y)*velocity_mult)).clamp(minClam,maxClam)
			#velocity = Input.get_last_mouse_velocity() * (-1)
			#print(startCur.distance_to(get_global_mouse_position()))
			curInput = false
			motion = true
			float_timer.start()

func createArrow():
	var arrow = ARROW.instantiate()
	var minus = Vector2(0,-10)
	arrow.position = get_local_mouse_position() - minus
	add_child(arrow)
	return arrow

func _on_float_timer_timeout():
	set_collision_layer_value(2,false)
	set_collision_mask_value(2,false)
	motion = false
	moveTo = null
	

func stickToObject(object):
	#var max_height = object.get_node("NocCollisionShape").get_shape().get_rect().size.y * -1
	#print(object.get_node("CollisionShape2D").get_shape().get_rect().size)
	numOfJumps = MAXJUMPS
	numOfSlings = MAXSLINGS
	#height_sticked = position.y
	#print(height_sticked)
	#if(height_sticked < max_height):
	#	height_sticked = max_height
	objectSticked = object
	objectSticked.get_parent().get_grabbed(self)
	tick_timer.start()

func stayDuringStick():
	if(objectSticked != null):
		#print(height_sticked)
		#position = objectSticked.position + Vector2(0,height_sticked)
		position = objectSticked.global_position

func freeze_time():
	Engine.time_scale = 0
	game.gameFrozen = true
	game_frozen = true

func unfreeze_time():
	Engine.time_scale = 1
	game.gameFrozen = false
	game_frozen = false

func grab():
	if(numOfGrabs == 0):
		return
	if Input.is_action_just_pressed("MouseRightClick"):
		#print("started grab")
		#Enable Grab Area
		grab_area.monitoring = true
		grab_area.monitorable = true
		grabbing = true
		
	if Input.is_action_just_released("MouseRightClick") and grabbing:
		#Check closest overlapping area
		#var closestParent
		var areas = grab_area.get_overlapping_areas()
		#print(areas)
		if(areas.size() > 0):
			#print("more than 0 areas")
			var closest = find_closest(areas)
			grab_area.monitoring = false
			grab_area.monitorable = false
			if closest == null:
				return
			
			if closest.name == "ProjectileGrab":
				closest.get_parent().stop_collision()
				#closest.get_parent().SPEED = 0
			moveTo = closest
			numOfGrabs -=1
			#Attach to it
			
		
		#print("ended grab")
		


func find_closest(arr):
	var clos
	#print(arr)
	for areas in arr:
		if (!clos):
			clos = areas
		if areas.global_position.distance_to(self.global_position) < clos.global_position.distance_to(self.global_position):
			clos = areas
	#print(clos)
	return clos

func move_to_position(endPosition,delta):
	if(abs(position.x - endPosition.global_position.x) > NEAR):
		float_timer.start()
		position.x = move_toward(position.x,endPosition.global_position.x,BIGACC*delta)
	else:
		stickToObject(endPosition)
		moveTo = null
		
func catch_a_parasite(_parasite):
	#Change depending on the parasite
	health = clamp(health + 25,0,MAXHEALTH)
	if (_parasite.parasiteAbility == null):
		return
	if (_parasite.parasiteAbility == "Grab"):
		MAXGRABS += 1

func _on_tick_timer_timeout():
	if(objectSticked != null and objectSticked.name != "ProjectileGrab"):
		objectSticked.get_parent().take_damage(10)

func take_damage(amount):
	if(!vulnerable):
		return
	health = clamp(health-amount,0,MAXHEALTH)
	print("Took " + str(amount) + " damage and now i have " + str(health) + " health!")
	if(health == 0):
		die()
	vulnerable = false
	invulnerability_timer.start()
	health_label.text = str(health)
	print("start invulnerability")

func get_healed(amount):
	health += amount
	health_label.text = str(health)
	print("Healed " + str(amount) + " damage and now i have " + str(health) + " health!")

func release_enemy():
	if(objectSticked != null):
		objectSticked.get_parent().released() 
		print(objectSticked.name)
	objectSticked = null


func _on_invulnerability_timer_timeout():
	print("stop invulnerability")
	vulnerable = true

func check_invulnerability():
	return vulnerable
	
func shoot(spawnPosition, spawnRotation, startingSpawnRotation, projectileCollision):
	if(!objectSticked):
		return
	if(objectSticked.name == "ProjectileGrab"):
		var projInstance = projectile.instantiate()
		projInstance.dir = spawnRotation
		projInstance.spawnPos = spawnPosition
		projInstance.spawnRot = startingSpawnRotation
		projInstance.zdex = z_index - 1
		projInstance.coll = projectileCollision
		game.add_child.call_deferred(projInstance)

func die():
	print("You died!")
	Engine.time_scale = 0.5
	get_node("CollisionShape2D").queue_free()
	die_timer.start()
	
func on_dietimer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
