############################## Main Global Variables ##############################
extends Node


#Player global variables
var player_position : Vector2
var player_coins : int
var player_hp : int
var player_max_hp : int
var player_ammo : int
var player_max_ammo : int

#Only use in global script!!!
var coin_scene : PackedScene = preload("res://scenes/entity/coin.tscn")

var rarities = {0 : 1000, #Common
				1 : 500, #Rare
				2 : 250, #Epic
				3 : 100} #Legendary


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
func spawn_particle(spawn_pos : Vector2, parent : Node, particle_scene : PackedScene):
		var new_particle = particle_scene.instantiate()
		parent.get_parent().call_deferred("add_child", new_particle)
		new_particle.global_position = spawn_pos


#---------------------------------------------------------------------------------------------------------------------------
func get_rarity(): #Generate a random rarity with weighted sums
	var weighted_sum := 0
	
	for n in rarities:
		weighted_sum += rarities[n]
	
	var output = randi_range(0, weighted_sum)
	
	for n in rarities:
		if output <= rarities[n]:
			return n
		output -= rarities[n]
