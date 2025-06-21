############################## Player Speed Upgrade ##############################
extends BaseUpgrade
class_name PlayerMultUpgrade

@export var player_mult_increase : float = 0.1

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(_player: Player):
	PlayerUpgradeStats.power_mult += player_mult_increase
 
