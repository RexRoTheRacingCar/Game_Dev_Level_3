############################## Game Script ##############################
extends Node2D


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
