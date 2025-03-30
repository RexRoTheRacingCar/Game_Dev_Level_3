############################## Player UI ##############################
extends CanvasLayer


#Label variables
@onready var player_hp: Label = $Control/PlayerHP
@onready var coins: Label = $Control/Coins


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	player_hp.text = str(Global.player_hp, " / ", Global.player_max_hp)
	coins.text = str(Global.player_coins)
