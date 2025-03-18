############################## Main Bullet Base ##############################
extends Resource
class_name BaseUpgrade

@export var texture : Texture2D
@export var upgrade_type : String

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet (KEEP BLANK)
func apply_upgrade(_bullet: Bullet):
	pass

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to player (KEEP BLANK)
func apply_player_upgrade(_player: Player):
	pass
