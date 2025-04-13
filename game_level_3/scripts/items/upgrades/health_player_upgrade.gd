############################## Health Upgrade ##############################
extends BaseUpgrade
class_name HealthPlayerUpgrade

@export var health_increase : int = 10

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player
func apply_player_upgrade(player: Player):
	player.p_health_component.max_health += health_increase
	player.p_health_component.health += health_increase
 
