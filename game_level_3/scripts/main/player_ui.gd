############################## Player UI ##############################
extends CanvasLayer


#Label variables
@export var hp_label : Label


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	hp_label.text = str(Global.player_hp, " / ", Global.player_max_hp)
