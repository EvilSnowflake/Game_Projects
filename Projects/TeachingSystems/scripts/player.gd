extends CharacterBody2D

@export var _speed: int = 200:
	set(value):
		_speed = value
	get:
		return _speed
		
@export var _health: float = 110.0
@export var _max_health: float = 110.0
@export var _damage_rate: float = 5.0

@onready var gun = %Gun
@onready var cyborg_player = %Cyborg_Player
@onready var player_sprite = %Player_Sprite
@onready var hurt_box = %Hurt_Box
@onready var health_bar = %Health_Bar

signal health_depleted

func _ready():
	_health = _max_health

func _physics_process(delta):
	var direction = Input.get_vector("Left","Right","Up","Down")
	velocity = direction * _speed
	move_and_slide()
	#print(direction[0])
	if(direction[0] < 0):
		player_sprite.flip_h = true
	elif (direction[0] > 0):
		player_sprite.flip_h = false
	
	if(velocity.length() > 0.0):
		play_run_animation()
	else:
		play_idle_animation()
	
	var overlapping_mobs = hurt_box.get_overlapping_bodies()
	_health -= _damage_rate * overlapping_mobs.size() * delta
	health_bar.value = (100 * _health)/_max_health
	if(_health <= 0.0 ):
		health_depleted.emit()

func play_idle_animation() -> void:
	cyborg_player.play("Idle")
	
func play_run_animation() -> void:
	cyborg_player.play("Run")
	
func add_speed(value: int):
	_speed += value
func add_max_health(value: int):
	_max_health += value
	_health = _max_health
func add_range(value: int):
	gun.set_range(value + gun.get_range())
func add_bullet_damage(value: int):
	gun.set_bullet_damage(gun.get_bullet_damage() + value)
func add_bullet_persistance(value: int):
	gun.set_bullet_persistance(gun.get_bullet_persistance() + value)
