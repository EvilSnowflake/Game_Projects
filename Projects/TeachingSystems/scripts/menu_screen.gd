extends Control

var stage_menu
var save_path = "user://SavedData.save"
#FILE SAVE ON %APPDATA%\Godot\app_userdata\TeachingSystems

@export var stage_buttons: Array[Button] = []
@export var stages_enabled = 1

@onready var controls = %Controls

func _ready():
	stage_menu = get_tree().get_root().get_node("Stage_Menu")
	for button in stage_buttons:
		button.pressed.connect(_on_stage_button_pressed.bind(button.text))
	load_data()
	unlock_enabled_stages()

func _on_stage_button_pressed(stg_num: String):
	print("Starting stage "+ stg_num)
	if(stage_menu.has_method("create_game")):
		stage_menu.create_game(int(stg_num))

func enable_propedia_button(num: int):
	if(num > 9):
		print("No such stage")
		return
	print("Enabling stage "+str(num))
	stages_enabled += 1
	save_data()
	unlock_enabled_stages()

func _on_controls_button_pressed():
	controls.show()

func _on_exit_pressed():
	get_tree().quit()

func unlock_enabled_stages():
	for i in range(len(stage_buttons)):
		if(i < stages_enabled):
			stage_buttons[i].disabled = false
		else:
			stage_buttons[i].disabled = true

func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_8(stages_enabled)
	print("SAVED!")

func load_data():
	if(FileAccess.file_exists(save_path)):
		var file = FileAccess.open(save_path,FileAccess.READ)
		stages_enabled = file.get_8()
		unlock_enabled_stages()
	else:
		print("NO SAVED DATA FOUND!")

func delete_data():
	if(FileAccess.file_exists(save_path)):
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		stages_enabled = 1
		file.store_8(stages_enabled)
		unlock_enabled_stages()
		print("PROGRESS DELETED!")
		
func _on_clear_data_pressed():
	delete_data()
