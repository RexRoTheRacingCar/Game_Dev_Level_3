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
var room_save : PackedScene

#Room arrays saving room resource arrays and modifying them. 
var fight_room_array : Array = []
var shop_room_array : Array = []
var reward_room_array : Array = []

var current_room = null
var current_room_mesh = null

@export var shop_chance : float = 0.35

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
	
	#Select a type of room based on a random float
	var rand_room_type := randf()
	
	if rand_room_type >= shop_chance:
		current_room = select_room(fight_room_array)
		Global.current_room_type = "fight"
		
	else:
		current_room = select_room(shop_room_array)
		Global.current_room_type = "shop"
	
	#Load room into the game and update Global Variables
	add_child(current_room)
	
	current_room_mesh = current_room.room_nav_mesh
	Global.global_map = current_room_mesh
	Global.destructable_layer = current_room.destructable_tilemap


#---------------------------------------------------------------------------------------------------------------------------
#Select a random room from selection, make sure it doesn't load same room 
func select_room(room_array : Array):
	var placeholder_array : Array = room_array.duplicate()
	placeholder_array.erase(room_save)
	
	var rand_select : int = randi_range(0, placeholder_array.size() - 1)
	room_save = placeholder_array[rand_select]
	var selected_room = placeholder_array[rand_select].instantiate()
	
	return selected_room
