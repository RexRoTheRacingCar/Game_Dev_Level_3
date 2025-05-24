############################## Main Room Generator ##############################
extends Node2D
class_name RoomGenerator

#All room resource lists
@export_group("Room Resources")
@export var fight_room_resource : RoomArray
@export var shop_room_resource : RoomArray
@export var reward_room_resource : RoomArray

@export_group("Misc")

#Room Counters
@export var minimum_rooms : int = 10
@export var maximum_rooms : int = 15

#MIGHT NOT USE v
var maximum_fight_rooms : int = 0 
var maximum_shop_rooms : int = 0
var maximum_reward_rooms : int = 0
#MIGHT NOT USE ^

var room_counter : int = 0

#Room arrays saving room resource arrays and modifying them. 
var fight_room_array : Array = []
var shop_room_array : Array = []
var reward_room_array : Array = []

var current_room = null
var current_room_mesh = null

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	room_counter = 0
	
	_update_room_arrays()


#---------------------------------------------------------------------------------------------------------------------------
func _update_room_arrays():
	#Update room arrays
	if fight_room_resource: #Fight room array
		maximum_fight_rooms = fight_room_resource.room_array.size()
		fight_room_array = fight_room_resource.room_array
	
	if shop_room_resource: #Shop room array
		maximum_shop_rooms = shop_room_resource.room_array.size()
		shop_room_array = shop_room_resource.room_array
	
	if reward_room_resource: #Reward room array
		maximum_reward_rooms = reward_room_resource.room_array.size()
		reward_room_array = reward_room_resource.room_array


#---------------------------------------------------------------------------------------------------------------------------
func generate_room():
	if current_room != null:
		current_room.queue_free()
		
		current_room = null
	var rand_room_type := randf()
	var rand_select : int
	
	if rand_room_type > 0.25:
		rand_select = randi_range(0, fight_room_array.size() - 1)
		current_room = fight_room_array[rand_select].instantiate()
	else:
		rand_select = randi_range(0, shop_room_array.size() - 1)
		current_room = shop_room_array[rand_select].instantiate()
	
	add_child(current_room)
	
	current_room_mesh = current_room.room_nav_mesh
