############################## Main Bullet Base ##############################
extends Resource
class_name BaseUpgrade

@export var texture : Texture2D
@export var upgrade_type : String

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet (KEEP BLANK)
@warning_ignore("unused_parameter")
func apply_upgrade(bullet: Bullet):
	pass

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player (KEEP BLANK)
@warning_ignore("unused_parameter")
func apply_player_upgrade(player: Player):
	pass
