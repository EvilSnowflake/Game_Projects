extends Area2D

@export var text_to_show: String
@export var show_type : MovingLabel.ShowTextType
@export var is_hidden: bool = false
@export var enable_finish_button: bool = false

func _ready():
	area_entered.connect(_on_text_area_entered)
	if(is_hidden):
		disable_and_hide_node()

func _on_text_area_entered(area: Area2D):
	#print("Text Area Entered")
	#area.emit_signal("text_changed",)
	if text_to_show == null or show_type == null :
		return
	var areaPar: MovingLabel = area.get_parent()
	areaPar.enable_finish_button()
	areaPar.set_text(text_to_show, show_type)
	queue_free()

func disable_and_hide_node() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED # = Mode: Disabled
	hide()

func enable_and_show_node() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT # = Mode: Inherit
	show()
