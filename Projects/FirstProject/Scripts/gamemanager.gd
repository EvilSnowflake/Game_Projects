extends Node

var score = 0
@onready var score_label = $Score_Label

func add_points():
	score += 1
	score_label.text = "You collected " + str(score) + " coins!"
