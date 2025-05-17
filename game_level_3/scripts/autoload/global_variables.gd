############################## Main Global Variables ##############################
extends Node


#Player global variables
var player_dead : bool
var player_position : Vector2
var player_velocity : Vector2
var player_coins : int
var player_hp : int
var player_max_hp : int
var player_ammo : int
var player_max_ammo : int

#Only use in global script!!!
var coin_scene : PackedScene = preload("res://scenes/entity/coin.tscn")


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


#---------------------------------------------------------------------------------------------------------------------------
#Generates a random rarity with weighted sums
func get_rarity(rarities : Dictionary):
	var total = 0
	for i in rarities: #Total rarity values
		total += rarities[i]
		
	var randfloat = randf() * total #Random float from 0.0 to 1.0 multiplied by the total
	
	for i in rarities:
		if randfloat < rarities[i]:
			return i
		
		randfloat -= rarities[i]


#---------------------------------------------------------------------------------------------------------------------------
func hit_stop(stop_time : float):
	Engine.time_scale = 0
	await get_tree().create_timer(stop_time, true, false, true).timeout
	Engine.time_scale = 1
