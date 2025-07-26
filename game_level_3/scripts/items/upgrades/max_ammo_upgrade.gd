############################## Max Ammo Upgrade ##############################
extends BaseUpgrade
class_name PlayerMaxAmmoUpgrade

@export var player_max_ammo_increase : float = 1.6

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	@warning_ignore("integer_division")
	var max_ammo_calc : int = roundi(float(player.P_WEAPON_CONTROLLER.max_ammo) / player_max_ammo_increase)
	player.P_WEAPON_CONTROLLER.max_ammo += clampi(max_ammo_calc, 1, 25)
