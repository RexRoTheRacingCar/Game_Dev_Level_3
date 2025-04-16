############################## Player Speed Upgrade ##############################
extends BaseUpgrade
class_name PlayerSpeedUpgrade

@export var player_speed_increase : float = 50

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.p_speed += player_speed_increase
 
