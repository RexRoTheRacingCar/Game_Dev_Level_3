############################## Main Room Generator ##############################
extends Node2D

@export var room_nav_region : NavigationRegion2D #The NavMesh Node
var room_nav_mesh : RID #The actual NavMesh

@onready var destructable_tilemap : TileMapLayer = $FloorFolder/DestructableMap
var destructable_detection_layer : TileMapLayer

@onready var portal_spawn_folder : Node2D = %PortalSpawnFolder
var portal_spawn_array : Array = []

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	room_nav_mesh = get_world_2d().get_navigation_map()
	portal_spawn_array = portal_spawn_folder.get_children()
	
	if destructable_tilemap:
		_create_destructable_tiles()


#---------------------------------------------------------------------------------------------------------------------------
func _create_destructable_tiles():
	#Get all tiles in destructable_tilemap
	destructable_detection_layer = destructable_tilemap.get_child(0)
	var tile_array = destructable_tilemap.get_used_cells()
	
	for tile in range(0, tile_array.size()):
		destructable_detection_layer.set_cell(tile_array[tile], 1, Vector2i(0, 0), 2)
