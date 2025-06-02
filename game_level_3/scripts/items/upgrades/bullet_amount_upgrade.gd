############################## Bullet Amount Upgrade ##############################
extends BaseUpgrade
class_name BulletAmountUpgrade

@export var bullet_amount_increase : int = 2

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_player_upgrade(player: Player):
	player.P_WEAPON_CONTROLLER.bullet_amount += bullet_amount_increase
