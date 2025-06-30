############################## Player UI ##############################
extends CanvasLayer

#Label variables
@export var player_hp : Label
@export var player_health_bar : ProgressBar

@export var coins : Label
@export var bullets : Label
@export var game_time : Label

#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	Global.game_timer += delta
	
	#Updating UI text and other GUI
	player_hp.text = str(Global.player_hp, " / ", Global.player_max_hp)
	
	player_health_bar.max_value = Global.player_max_hp
	player_health_bar.value = Global.player_hp
	
	coins.text = str(Global.player_coins)
	bullets.text = str(Global.player_ammo, " / ", Global.player_max_ammo)
	
	#Game Timer
	var mils = fmod(Global.game_timer, 1) * 1000 
	var secs = fmod(Global.game_timer, 60)
	var mins = fmod(Global.game_timer, 60 * 60) / 60
	var time_passed = "%02d : %02d : %03d" % [mins, secs, mils]
	game_time.text = str(time_passed)
