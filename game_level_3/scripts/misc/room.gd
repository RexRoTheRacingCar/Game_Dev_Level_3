############################## Main Room Generator ##############################
extends Node2D

@export var room_nav_region : NavigationRegion2D #The NavMesh Node
var room_nav_mesh : RID #The actual NavMesh

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	room_nav_mesh = get_world_2d().get_navigation_map()
