############################## Main Global Variables ##############################
extends Node


#Player global variables
var player_position : Vector2
var player_coins : int
var player_hp : int
var player_max_hp : int


#Only use in global script!!!
var coin : PackedScene = preload("res://scenes/entity/coin.tscn")


#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	randomize()


#---------------------------------------------------------------------------------------------------------------------------
func spawn_coins(coin_amount : int, spawn_pos : Vector2, parent : Node):
	for coins in range(0, coin_amount):
		var new_coin = coin.instantiate()
		var rand_spawn = 30.0
		parent.get_parent().call_deferred("add_child", new_coin)
		new_coin.global_position = Vector2(spawn_pos.x + randf_range(rand_spawn, -rand_spawn), spawn_pos.y + randf_range(rand_spawn / 2, -rand_spawn / 2))
