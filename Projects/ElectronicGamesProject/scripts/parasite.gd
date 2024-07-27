extends Node2D


const BIGACC = 400
const SMALLACC = 50
const NEAR = 40

@onready var search_zone = $SearchZone
@onready var animation_player = $AnimationPlayer
@onready var game = get_tree().get_root().get_node("Game")

var engage = false
var nearestNOC
var playerClose = null
var foundNOC = false
var nocsParent
var NOCSPARENTNAME = "Enemies"
var nocNum = 0
var isUnpoweredPar = false
var isRemenantPar = false
var parasiteAbility
var healthRestore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#nocsParent = get_tree().get_root().get_node("Game").get_node(NOCSPARENTNAME)
	#print(nocsParent.get_child_count())
	#print(nocNum)
	if isUnpoweredPar:
		animation_player.play("Unpowered")
	if isRemenantPar:
		animation_player.play("Remenant")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isUnpoweredPar):
		return
	#print(NOCSPARENT.get_child_count())
	#if nocsParent.get_child_count() > 0:
	#	move_to_position(nocsParent.get_child(nocNum),delta,SMALLACC)
	if(playerClose!= null):
		check_close()
	if(!engage):
		#Make a spontanious movement
		
		position.x = position.x + SMALLACC*delta
		#position.y = position.y + 30*delta
	else:
		move_to_position(nearestNOC,delta,SMALLACC)

#This object will constantly check if the user is close to it
# if they are not then it will move in random places with specific bounds
# if they are then it will either move a away from them or if there is a noc
#nearby then they will infect it and fight the user

#Also if the user catches it they will consume it for health

func check_close():
	if(foundNOC):
		return
	var closest
	
	var bodies = search_zone.get_overlapping_bodies()
	
	#print(areas)
	if(bodies.size() > 0):
		closest = find_closest(bodies)
		
	if(closest):
		foundNOC = true
		print(closest.position)
		
		nearestNOC = closest
		engage = true
		#Get into the NOC and make it an enemy	

func _on_search_zone_body_entered(body):
	if(body.name ==  "Player"):
		playerClose = body
		print(body.name + " entered!")
	


func find_closest(arr):
	var clos
	for body in arr:
		if (!clos and body.name.begins_with("NOC")):
			clos = body
		elif (!clos and !body.name.begins_with("NOC")):
			continue
		if body.global_position.distance_to(self.global_position) < clos.global_position.distance_to(self.global_position) and body.name.begins_with("NOC"):
			clos = body
	return clos
	
func move_to_position(endPosition,delta,acceleration):
	if(abs(position.x - endPosition.position.x) > NEAR):
		#position.x = move_toward(position.x,endPosition.position.x,BIGACC*delta)
		position = position.move_toward(endPosition.position, acceleration*delta)
	else:
		nearestNOC.get_possesed(self,playerClose)
		animation_player.play("Shrink")
		engage = false


func _on_search_zone_body_exited(body):
	if(body.name ==  "Player"):
		playerClose = null
		print(body.name + " exited!")
		animation_player.play("Shrink")
		

func become_unpowered():
	print("Im unpowered")
	isUnpoweredPar = true
	parasiteAbility = "Grab"
	


func _on_catch_zone_body_entered(body):
	if(!isUnpoweredPar):
		print("Still Empowered")
		return
	if(body.name ==  "Player"):
		body.get_healed(35)
		body.catch_a_parasite(self)
		animation_player.play("Shrink")

func become_remenant():
	isRemenantPar = true
	print("I am remenant")
