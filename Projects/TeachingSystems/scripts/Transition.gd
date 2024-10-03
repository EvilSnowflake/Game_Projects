extends ColorRect

var _graphicVanish
var _graphicAppear

@onready var color_rect_animations = $ColorRectAnimations
@onready var menu_screen = %MenuScreen
@onready var starting_interface = %Starting_Interface


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(color.a == 1):
		_graphicVanish.visible = false
		_graphicVanish.mouse_filter = MOUSE_FILTER_IGNORE
		_graphicAppear.visible = true
		_graphicAppear.mouse_filter = MOUSE_FILTER_STOP
	
	if(color.a != 0):
		return
	
	
	#if (starting_interface.visible == true and mouseClick):
	#	trans(starting_interface,menu_screen)
	

func trans(van, app) -> void:
	_graphicAppear = app
	_graphicVanish = van
	color_rect_animations.play("Appear")
	color_rect_animations.queue("Fade")
	
