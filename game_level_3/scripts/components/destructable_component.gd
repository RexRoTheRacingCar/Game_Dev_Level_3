############################## Destructable Component ##############################
extends Area2D
class_name DestructableComponent

@export var tileset : TileMapLayer
@export var collison : CollisionPolygon2D

var tile_pos := Vector2i(0, 0)
var tile_d
var tile_global_position : Vector2

var is_being_hit : bool = false :
	set(new_value):
		is_being_hit = new_value
		while is_being_hit == true:
			_tile_hit(hitting_node)
			await get_tree().create_timer(0.2, false).timeout

var hitting_node : Node

#--------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	is_being_hit = false
	
	if Global.destructable_layer:
		tileset = Global.destructable_layer
		tile_pos = tileset.local_to_map(global_position)
		tile_d = tileset.get_cell_tile_data(tile_pos)
		tile_global_position = tileset.to_global(tileset.map_to_local(tile_pos))
		
		collison.scale = tile_d.get_custom_data("hitbox_size")


#Detect areas & bodies
#--------------------------------------------------------------------------------------------------------------------------
func _on_area_entered(area): 
	hitting_node = area
	is_being_hit = true

func _on_body_entered(body):
	hitting_node = body
	is_being_hit = true

func _on_area_exited(_area):
	is_being_hit = false

func _on_body_exited(_area):
	is_being_hit = false


#When tile is hit
#--------------------------------------------------------------------------------------------------------------------------
func _tile_hit(body):
	if body.is_in_group("not_destructive") == false and body.is_in_group("walls") == false:
		tile_d = tileset.get_cell_tile_data(tile_pos)
		
		#If tile deletes before area updates, delete area and end script
		if tile_d == null:
			queue_free()
			return
		
		var destroy_sound = tile_d.get_custom_data("break_audio")
		if destroy_sound:
			AudioManager.play_2d_sound(destroy_sound, "SFX", global_position)
		
		if tile_d.get_custom_data("coin_chance") != 0.0:
			_coin_drop(tile_d.get_custom_data("coin_chance"), tile_d.get_custom_data("coin_amount"))
		_generate_scenes()
		
		#Update destructable tilseset
		if tile_d.get_custom_data("delete") == false:
			#Get alternative cell_id
			var tile_alternate_id : int = tileset.get_cell_alternative_tile(tile_pos)
			
			#If cell is flipped, apply changes and flip it
			if tile_alternate_id and TileSetAtlasSource.TRANSFORM_FLIP_H:
				tileset.set_cell(tile_pos, tileset.get_cell_source_id(tile_pos), 
				tileset.get_cell_atlas_coords(tile_pos) - Vector2i(tile_d.get_custom_data("offset"), 0),
				tile_alternate_id | TileSetAtlasSource.TRANSFORM_FLIP_H)
			
			#If it isn't flipped, just apply changes
			else:
				tileset.set_cell(tile_pos, tileset.get_cell_source_id(tile_pos), 
				tileset.get_cell_atlas_coords(tile_pos) - Vector2i(tile_d.get_custom_data("offset"), 0))
			
			#Update collision and camera shake
			collison.scale = tile_d.get_custom_data("hitbox_size")
			
			#Stop monitoring for a moment
			set_collision_mask_value(1, false)
			await get_tree().create_timer(0.375, false).timeout
			set_collision_mask_value(1, true)
		
		else:
			#Delete tile and self
			tileset.erase_cell(tile_pos)
			queue_free()


#Spawn scene/s at tile position with camera shake
#--------------------------------------------------------------------------------------------------------------------------
func _generate_scenes():
	#Apply screen_shake
	Camera.apply_camera_shake(tile_d.get_custom_data("screen_shake")) 
	
	#Get scene array from tile, if it exists instantiate the scenes at the tile's position
	var scene_array : Array = tile_d.get_custom_data("hit_scenes")
	
	if scene_array.is_empty() == false:
		for scenes in range(0, scene_array.size()):
			#Instantiate the scene, get global position based on tile_pos, add the scene as a child
			var new_scene = scene_array[scenes].instantiate()
			new_scene.global_position = tile_global_position
			get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_scene)


#Chance to drop coins
#--------------------------------------------------------------------------------------------------------------------------
func _coin_drop(coin_chance, coin_amount):
	if randf() < coin_chance: #Possible chance to spawn a coin
		for coins in randi_range(1, coin_amount):
			var new_coin = Global.coin_scene.instantiate()
			new_coin.global_position = tile_global_position
			get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_coin)
