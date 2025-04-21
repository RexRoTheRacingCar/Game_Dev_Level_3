############################## Max Ammo Upgrade ##############################
extends BaseUpgrade
class_name PlayerMaxAmmoUpgrade

@export var player_max_ammo_increase : int = 6

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.p_weapon_controller.max_ammo += player_max_ammo_increase
