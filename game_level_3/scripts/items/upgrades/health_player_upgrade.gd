############################## Health Upgrade ##############################
extends BaseUpgrade
class_name HealthPlayerUpgrade

@export var health_increase : int = 10

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.P_HEALTH_COMPONENT.max_health += health_increase
	player.P_HEALTH_COMPONENT.health += health_increase
 
