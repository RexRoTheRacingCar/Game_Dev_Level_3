############################## Burst Fire Upgrade ##############################
extends BaseUpgrade
class_name PlayerBurstUpgrade

@export var player_burst_increase : int = 1

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.p_burst_amount += player_burst_increase
 
