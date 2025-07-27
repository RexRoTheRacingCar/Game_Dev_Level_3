############################## Game Script ##############################
extends Node2D


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	Global.current_main_scene = "Game"
	Global.player_dead = false
	Global.player_coins = 0
	Global.rooms_cleared = 0
	Global.gems = 0
	PlayerUpgradeStats.power_mult = 1.0


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	if Global.player_dead == true:
		Global.current_main_scene = "Start Menu"
		var _main_menu = get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
