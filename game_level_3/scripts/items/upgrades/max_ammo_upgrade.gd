############################## Max Ammo Upgrade ##############################
extends BaseUpgrade
class_name PlayerMaxAmmoUpgrade

@export var player_max_ammo_increase : float = 1.6

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	@warning_ignore("integer_division")
	player.P_WEAPON_CONTROLLER.max_ammo += roundi(player.P_WEAPON_CONTROLLER.max_ammo / player_max_ammo_increase)
