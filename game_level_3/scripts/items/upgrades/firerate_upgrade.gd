############################## Firerate Upgrade ##############################
extends BaseUpgrade
class_name FireratePlayerUpgrade

@export var reload_decrease : float = 2

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.p_weapon_controller.firerate /= reload_decrease
