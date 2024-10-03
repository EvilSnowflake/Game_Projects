extends CharacterBody2D

@onready var game
@onready var player = $"../Player"


@onready var drone_player = $Drone_Player

@export var _speed: int = 50
@export var _health: int = 3
@export var receives_knockback: bool = true
#const _PUSH_FORCE: int = 15.0
#const _MIN_PUSH_FORCE: int = 10.0

func _physics_process(_delta):
	if(_health > 0 and player != null):
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * _speed
		move_and_slide()
	
	
	##Not used
	#for c in get_slide_collision_count():
	#	var coll = get_slide_collision(c)
	#	if coll.get_collider() is RigidBody2D:
	#		var push_force = (_PUSH_FORCE * velocity.length() / _speed) + _MIN_PUSH_FORCE
	#		coll.get_collider().apply_central_impulse(-coll.get_normal() * push_force)
	##Not used

func take_damage(amount: int):
	_health -= amount
	drone_player.play("Hit")
	if(_health <= 0):
		if(game == null):
			game = get_parent()
		if(game.has_method("decrease_enemy_number_by_one")):
			game.decrease_enemy_number_by_one()
		drone_player.play("Death")
	else:
		drone_player.queue("Float")

func receive_knockback(knockback_strength: float):
	if(receives_knockback):
		var knockback_direction = player.global_position.direction_to(global_position)
		var knockback = knockback_direction * knockback_strength
		global_position += knockback

func set_game(parnt: Node2D):
	game = parnt

