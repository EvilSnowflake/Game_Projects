extends CharacterBody2D

@onready var float_timer = $FloatTimer

const SPEED = 200.0
const JUMP_VELOCITY = -250.0
const acc = 20
const friction = 50
const wall_jump_pushbck = 100
const velocity_mult = 3
const ARROW = preload("res://scenes/arrow.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*0.75
var tempAr
var curInput = false
var startCur = Vector2()
var maxClam = Vector2(200,500)
var minClam = Vector2(-200,-500)
var motion = false

func _physics_process(delta):
	print(velocity)
	#print("x")
	#var input_dir: Vector2 = input()
	var direction = Input.get_axis("MoveLeft", "MoveRight")
	if direction:
		#print(velocity.x)
		#velocity.x = direction*SPEED
		accelerate(direction)
	elif !direction and !motion:
		add_friction()
	jump(delta)
	move_and_slide()
	
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

func jump(delta):
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("Space"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		if is_on_wall() and Input.is_action_pressed("MoveRight"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -wall_jump_pushbck
		if is_on_wall() and Input.is_action_pressed("MoveLeft"):
			velocity.y = JUMP_VELOCITY
			velocity.x = wall_jump_pushbck
	#elif Input.is_action_just_pressed("Space") and is_on_wall():
	#	velocity.x = JUMP_VELOCITY

func sling():
	if is_on_floor():
		
		if Input.is_action_just_pressed("MouseLeftClick"):
			tempAr = createArrow()
			curInput = true
			velocity.x = 0
			startCur = get_global_mouse_position()
			print(get_global_mouse_position())
			
		elif Input.is_action_just_released("MouseLeftClick") and curInput:
			#if tempAr:
			tempAr.queue_free()
			#var pushPower = startCur.distance_to(get_global_mouse_position())
			velocity = (Vector2((get_global_mouse_position().x - startCur.x)*velocity_mult,
			(get_global_mouse_position().y - startCur.y)*velocity_mult)).clamp(minClam,maxClam)
			#velocity = Input.get_last_mouse_velocity() * (-1)
			print(velocity)
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

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("MoveLeft","MoveRight")
	input_dir = input_dir.normalized()
	return input_dir


func _on_float_timer_timeout():
	motion = false
