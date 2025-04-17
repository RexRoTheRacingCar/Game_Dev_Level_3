############################## Player Speed Upgrade ##############################
extends BaseUpgrade
class_name PlayerResistanceUpgrade

@export var player_resistance_increase : float = 0.1

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.p_damage_resistance += player_resistance_increase
 
