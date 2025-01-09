extends Control

class_name SoundControl

@onready var _return_button = $MarginContainer/HBoxContainer/ReturnButton
@onready var _MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var _SFX_BUS_ID = AudioServer.get_bus_index("Sfx")
@onready var _music_slider: Slider = $MarginContainer/HBoxContainer/VBoxContainer2/MusicSlider
@onready var _sfx_slider: Slider = $MarginContainer/HBoxContainer/VBoxContainer2/SFXSlider2

func _ready():
	_music_slider.value_changed.connect(_on_music_slider_value_changed)
	_sfx_slider.value_changed.connect(_on_sfx_slider_value_change)
	_return_button.button_down.connect(on_return_button_down)
	_music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_MUSIC_BUS_ID))
	_sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_SFX_BUS_ID))

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(_MUSIC_BUS_ID, linear_to_db(value))
	
	AudioServer.set_bus_mute(_MUSIC_BUS_ID, value < .05)
	
func _on_sfx_slider_value_change(value):
	AudioServer.set_bus_volume_db(_SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(_SFX_BUS_ID, value < .05)

func on_return_button_down():
	hide()
