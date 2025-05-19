############################## Possible Room Resource Array ##############################
extends Resource
class_name RoomArray

#Fight, Shop, Reward 
@export var array_type : String 

#Array of all possible rooms of array_type. 
@export var room_array : Array[PackedScene] = []


#---------------------------------------------------------------------------------------------------------------------------
