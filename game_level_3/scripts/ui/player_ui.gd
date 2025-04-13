############################## Player UI ##############################
extends CanvasLayer


#Label variables
@export var player_hp : Label
@export var player_health_bar : ProgressBar

@export var coins : Label


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	#Updating UI text and other GUI
	player_hp.text = str(Global.player_hp, " / ", Global.player_max_hp)
	
	player_health_bar.max_value = Global.player_max_hp
	player_health_bar.value = Global.player_hp
	
	coins.text = str(Global.player_coins)
