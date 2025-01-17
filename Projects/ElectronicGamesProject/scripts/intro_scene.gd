extends Control

@onready var char_timer = $CharTimer
@onready var intro_text = $MarginContainer/VBoxContainer/IntroText
@onready var audio_stream_player = $AudioStreamPlayer
@onready var v_box_container = $MarginContainer/VBoxContainer

var _char_count: int = 0
var texts_to_show: Array[String]
var texts_number: int = 0

@export var menuLevel = "res://scenes/start_menu.tscn"

func _ready():
	char_timer.timeout.connect(_chartimer_timeout)
	for child: Label in v_box_container.get_children():
		texts_to_show.append(child.text)
		texts_number += 1
	audio_stream_player.finished.connect(_audioplayer_finished)

func _process(delta):
	for i in range(texts_number):
		var speedPerc: float = (_char_count*(100 - (10*i)))/100
		v_box_container.get_child(i).text = "%s" % texts_to_show[i].substr(0,int(speedPerc))
		#print(speedPerc)
	
func _chartimer_timeout():
	_char_count += 1

func _audioplayer_finished():
	get_tree().change_scene_to_file(menuLevel)
