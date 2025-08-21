############################## Main Room Generator ##############################
extends Node2D
class_name RoomGenerator

#All room resource lists
@export_group("Room Resources")
@export var fight_room_resource : RoomArray
@export var shop_room_resource : RoomArray
@export var boss_room_resource : RoomArray

@export_group("Misc")

#Room Counters
@export var minimum_rooms : int = 10
@export var maximum_rooms : int = 15

var room_counter : int = 0
var room_save : PackedScene

#Room arrays saving room resource arrays and modifying them. 
var fight_room_array : Array = []
var shop_room_array : Array = []
var boss_room_array : Array = []

var current_room = null
var current_room_mesh = null

@export var shop_chance : float = 0.35

const LOBBY_ROOM = preload("res://scenes/misc/rooms/lobby_room.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	room_counter = 0
	
	_update_room_arrays()


#---------------------------------------------------------------------------------------------------------------------------
func _update_room_arrays():
	#Update room arrays
	if fight_room_resource: #Fight room array
		fight_room_array = fight_room_resource.room_array
	
	if shop_room_resource: #Shop room array
		shop_room_array = shop_room_resource.room_array
	
	if boss_room_resource: #Boss room array
		boss_room_array = boss_room_resource.room_array


#---------------------------------------------------------------------------------------------------------------------------
func generate_room():
	if current_room != null:
		current_room.queue_free()
		current_room = null
	
	#Select a type of room based on a random float
	var rand_room_type := randf()
	
	if rand_room_type <= shop_chance:
		current_room = select_room(shop_room_array)
		Global.current_room_type = "shop"
	else:
		current_room = select_room(fight_room_array)
		Global.current_room_type = "fight"
	
	#Load room into the game and update Global Variables
	add_child(current_room)
	
	current_room_mesh = current_room.room_nav_mesh
	_update_global_var()


#---------------------------------------------------------------------------------------------------------------------------
func _update_global_var():
	Global.global_map = current_room_mesh
	Global.destructable_layer = current_room.destructable_tilemap


#Load the starting lobby screen
#---------------------------------------------------------------------------------------------------------------------------
func load_lobby_room():
	Global.current_room_type = "lobby"
	
	if current_room != null:
		current_room.queue_free()
		current_room = null
	
	current_room = LOBBY_ROOM.instantiate()
	add_child(current_room)
	
	current_room_mesh = current_room.room_nav_mesh
	_update_global_var()


#Load a boss room
#---------------------------------------------------------------------------------------------------------------------------
func load_boss_room():
	if current_room != null:
		current_room.queue_free()
		current_room = null
	
	current_room = select_room(boss_room_array)
	Global.current_room_type = "boss"
	
	#Load room into the game and update Global Variables
	add_child(current_room)
	
	current_room_mesh = current_room.room_nav_mesh
	_update_global_var()


#---------------------------------------------------------------------------------------------------------------------------
#Select a random room from selection, make sure it doesn't load same room 
func select_room(room_array : Array):
	var placeholder_array : Array = room_array.duplicate()
	placeholder_array.erase(room_save)
	
	var rand_select : int = randi_range(0, placeholder_array.size() - 1)
	room_save = placeholder_array[rand_select]
	var selected_room = placeholder_array[rand_select].instantiate()
	
	return selected_room
