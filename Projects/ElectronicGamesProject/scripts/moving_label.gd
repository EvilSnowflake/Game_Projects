extends Node2D

class_name MovingLabel

signal text_changed

enum ShowTextType { CHARTOCHAR, INSTANT }

var _text: String = ""
var _texts: Array[String] = []
var _type: ShowTextType
var _types: Array[ShowTextType] = []
var _char_count: int = 0
var _showing_text = false
var _main_menu = "res://scenes/start_menu.tscn"

@onready var _text_var : Label = %Text
@onready var text_change_timer = %TextChangeTimer
@onready var animation_player = %AnimationPlayer
@onready var fade_timer = %FadeTimer
@onready var finish_button = %FinishButton

#Make a 2d label that follows the player and depending on the place in the level
#	show the appropriate text (instructions, lore, etc)

func _ready():
	text_changed.connect(_start_modifying_text_var)
	text_change_timer.timeout.connect(_on_text_timer_timeout)
	fade_timer.timeout.connect(_on_fade_timer_timeout)
	
func _process(_delta):
	_text_var.text = "%s" % _text.substr(0,_char_count)
	
	if not(_texts.is_empty()) and not(_showing_text):
		#print(_texts)
		#var first_txt = _texts.pop_front()
		#var first_tp = _types.pop_front()
		_text = _texts.pop_front()
		_type = _types.pop_front()
		emit_signal("text_changed")
		

func _start_modifying_text_var():
	_text_var.modulate = Color(1, 1, 1)
	_showing_text = true
	if _type == ShowTextType.CHARTOCHAR :
		text_change_timer.start()
	elif _type == ShowTextType.INSTANT :
		_char_count = -1
		fade_timer.start()

func _on_text_timer_timeout():
	if _char_count == _text.length():
		_char_count = -1
		text_change_timer.stop()
		fade_timer.start()
		return
	
	_char_count += 1

func _on_fade_timer_timeout():
	animation_player.play("Fade")

func set_text(new_text: String, how_to_show: ShowTextType):
	
	#_text = new_text
	_texts.append(tr(new_text))
	#_type = how_to_show
	_types.append(how_to_show)
	
	#emit_signal("text_changed")

func erase_text():
	_text = ""
	_char_count = 0
	_showing_text = false

func enable_finish_button():
	finish_button.disabled = false

func _on_finish_button_pressed():
	get_tree().change_scene_to_file(_main_menu)
