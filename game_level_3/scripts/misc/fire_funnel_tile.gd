############################## Fire Funnel Trap ##############################
extends Node2D

@onready var animation_player = $AnimationPlayer
const FIRE_TRAP_SFX = preload("res://assets/audio/diegetic_sfx/fire_trap.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.room_cleared.connect(_stop_the_fire)
	animation_player.get_animation(animation_player.current_animation).loop_mode = 1


#---------------------------------------------------------------------------------------------------------------------------
func _stop_the_fire():
	animation_player.get_animation(animation_player.current_animation).loop_mode = 0


#---------------------------------------------------------------------------------------------------------------------------
func _fire_audio():
	if global_position.distance_to(Global.player_position) < 450:
		AudioManager.play_2d_sound(FIRE_TRAP_SFX, "SFX", global_position, true)
