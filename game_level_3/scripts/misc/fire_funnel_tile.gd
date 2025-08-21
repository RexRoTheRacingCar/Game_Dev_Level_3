############################## Fire Funnel Trap ##############################
extends Node2D

@onready var animation_player = $AnimationPlayer

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.room_cleared.connect(_stop_the_fire)
	animation_player.get_animation(animation_player.current_animation).loop_mode = 1


#---------------------------------------------------------------------------------------------------------------------------
func _stop_the_fire():
	animation_player.get_animation(animation_player.current_animation).loop_mode = 0
	
