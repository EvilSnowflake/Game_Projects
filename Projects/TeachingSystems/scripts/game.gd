extends Node2D

@onready var path_follow_2d = %PathFollow2D
@onready var spawn_timer = %Spawn_Timer
@onready var pause_menu = %Pause_Menu
@onready var wave_announcer = %Wave_Announcer
@onready var player = $Player

@export var _propedia_num: int = 1
@export var _enemies_left: int = 0
@export var _enemies_left_alive: int = 0
@export var _wave: int = 0

var _max_waves: int = 10
var stage_menu
var _paused: bool = false

func _ready():
	spawn_timer.start()

func _process(_delta):
	if(Input.is_action_just_pressed("Escape")):
		pause()

func spawn_enemy():
	var new_mob = preload("res://scenes/enemy.tscn").instantiate()
	path_follow_2d.progress_ratio = randf()
	new_mob.global_position = path_follow_2d.global_position
	add_child(new_mob)
	if(new_mob.has_method("set_game")):
		new_mob.set_game(self)

func _on_spawn_timer_timeout():
	if(_enemies_left > 0):
		print("Add enemy")
		spawn_enemy()
		_enemies_left -= 1
		_enemies_left_alive += 1
	
	if(_enemies_left_alive == 0):
		spawn_timer.stop()
		await get_tree().create_timer(2.0).timeout
		
		if(_wave < _max_waves):
			_increase_wave()
			spawn_timer.start()
			return
			
		return_to_stage_menu()

func pause():
	if(_paused):
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	_paused = !_paused

func _on_resume_button_pressed():
	pause()

func change_propedia(num: int):
	_propedia_num = num

func set_wave_enemies(num: int):
	_enemies_left = num

func decrease_enemy_number_by_one():
	print("enemy died!")
	_enemies_left_alive -= 1
	player.add_bullet_damage(1)
	player.add_bullet_persistance(1)
	player.add_speed(10)
	player.add_max_health(10)

func _increase_wave():
	_wave += 1
	set_wave_enemies(_wave * _propedia_num)
	wave_announcer.text = str(_propedia_num)+"x"+str(_wave)
	wave_announcer.get_child(0).play("Appear")
	print("Wave increased")

func read_stage_menu(menu: Node2D):
	stage_menu = menu

func return_to_stage_menu():
	if(stage_menu.has_method("exit_game")):
		queue_free()
		print("Finished stage "+str(_propedia_num))
		stage_menu.exit_game()
	else:
		get_tree().quit()


func _on_exit_button_pressed():
	return_to_stage_menu()


func _on_player_health_depleted():
	return_to_stage_menu()
	

