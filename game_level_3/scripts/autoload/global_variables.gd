############################## Main Global Variables ##############################
extends Node

#World global variables
var current_main_scene : String :
	set(new_value):
		current_main_scene = new_value
		
		match current_main_scene:
			"Game":
				Camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
			
			"Start Menu":
				Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
				Camera.shake_amount = 0
				Global.player_position = Vector2.ZERO

var enemy_count : int
var enemy_wave : bool
var wave_counter : int = 0
var wave_time : float
var current_max_waves : int = 0
var active_enemy_array : Array
var rooms_cleared : int = 0

var global_map
var destructable_layer : TileMapLayer
var current_room_type : String
var shops_in_room : int = 0

var game_timer : float = 0.0

var hidden_chance : float = 0.925 #Range from 0.0 to 1.0
var knockback_ease : float = 7.5

#Player global variables
var player : Player
var player_dead : bool
var player_position : Vector2
var player_velocity : Vector2
var player_coins : int
var player_hp : int
var player_max_hp : int
var player_ammo : int
var player_max_ammo : int
var player_rerolls : int 

var gems : int = 0

#Only use in global script!!!
var coin_scene : PackedScene = preload("res://scenes/entity/coin.tscn")


#Global Signals (The signals are used, warning ignore is to stop sending warnings in the debug menu)
@warning_ignore("unused_signal")
signal shop_reroll
@warning_ignore("unused_signal")
signal room_changed
@warning_ignore("unused_signal")
signal portal_entered
@warning_ignore("unused_signal")
signal room_cleared


#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	randomize()
	Engine.time_scale = 1


#---------------------------------------------------------------------------------------------------------------------------
func spawn_coins(coin_amount : int, spawn_pos : Vector2, parent : Node):
	for coins in range(0, coin_amount):
		var new_coin = coin_scene.instantiate()
		var rand_spawn = 30.0
		parent.get_parent().call_deferred("add_child", new_coin)
		new_coin.global_position = Vector2(spawn_pos.x + randf_range(rand_spawn, -rand_spawn), spawn_pos.y + randf_range(rand_spawn / 2, -rand_spawn / 2))


#---------------------------------------------------------------------------------------------------------------------------
#Function spawns a scene (Used for particles) at a given position, from a parent, with a packed scene of choice
func spawn_particle(spawn_pos : Vector2, parent : Node, particle_scene : PackedScene):
	var new_particle = particle_scene.instantiate()
	parent.get_parent().call_deferred("add_child", new_particle)
	new_particle.global_position = spawn_pos
	
	return new_particle


#---------------------------------------------------------------------------------------------------------------------------
#Generates a random rarity with weighted sums
func get_rarity(rarities : Dictionary):
	var total = 0
	for i in rarities: #Total rarity values
		total += rarities[i]
	
	#Random float from 0.0 to 1.0 multiplied by the total
	var randfloat = randf() * total
	
	for i in rarities:
		if randfloat < rarities[i]:
			return i
		
		randfloat -= rarities[i]


#---------------------------------------------------------------------------------------------------------------------------
func hit_stop(stop_time : float):
	Engine.time_scale = 0
	await get_tree().create_timer(stop_time, true, false, true).timeout
	Engine.time_scale = 1


#Finds a random point on a NavMesh on a spesific layer
#---------------------------------------------------------------------------------------------------------------------------
func rand_nav_mesh_point(nav_map, layer : int, uniform : bool) -> Vector2:
	return NavigationServer2D.map_get_random_point(nav_map, layer, uniform)


#Returns the closest point to a NavMesh from a certain target point
#---------------------------------------------------------------------------------------------------------------------------
func get_nav_mesh_point(nav_map, target_point : Vector2, min_dist_from_edge : float) -> Vector2:
	var closest_point := NavigationServer2D.map_get_closest_point(nav_map, target_point)
	var delta := closest_point - target_point
	var is_on_map = delta.is_zero_approx()
	#If it wasn't on the map, push towards map
	if not is_on_map and min_dist_from_edge > 0:
		delta = delta.normalized()
		closest_point += delta * min_dist_from_edge
	return closest_point


#Weighted lerp function to account for delta time
#---------------------------------------------------------------------------------------------------------------------------
func weighted_lerp(weight : float, delta : float) -> float:
	return 1.0 - exp(-weight * delta)


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event):
	if event.is_action_pressed("reroll") and Global.current_room_type == "shop" and Global.player_rerolls > 0 and Global.shops_in_room > 0:
		emit_signal("shop_reroll")
		Global.player_rerolls -= 1
