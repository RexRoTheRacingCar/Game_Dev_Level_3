############################## Game (Delete or Change Later) ##############################
extends Node2D

const ENEMY := preload("res://scenes/entity/enemy/test_enemy.tscn")
const EXPLODE_ENEMY := preload("res://scenes/entity/enemy/exploding_enemy_1.tscn")
const BRUTE_ENEMY := preload("res://scenes/entity/enemy/brute_enemy.tscn")

const SPAWN_ANIMATION = preload("res://scenes/entity/spawn_animation.tscn")


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		var spawn_anim = Global.spawn_particle(get_global_mouse_position(), $Player, SPAWN_ANIMATION)
		spawn_anim.enemy_scene = BRUTE_ENEMY


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	Global.current_main_scene = "Game"
	Global.player_dead = false
	Global.player_coins = 0
	PlayerUpgradeStats.power_mult = 1.0


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	if Global.player_dead == true:
		get_tree().quit()
