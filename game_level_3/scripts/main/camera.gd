############################## Global Camera ##############################
extends Camera2D


#Camera shake variables
const SHAKE_FADE_RATE : float = 15.0
const SHAKE_MULTIPLIER : float = 1.0
const MAX_SHAKE : float = 35.0
var shake_amount : float = 0.0
@onready var zoom_amount : float = 1

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	offset = Vector2.ZERO
	shake_amount = 0
	zoom = Vector2(zoom_amount, zoom_amount)


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	#Camera shake
	shake_amount = clamp(lerp(shake_amount, 0.0, Global.weighted_lerp(SHAKE_FADE_RATE, delta)), 0.0, MAX_SHAKE * SHAKE_MULTIPLIER)
	offset = lerp(offset, get_random_offset(), Global.weighted_lerp(30, delta))
	
	global_position = Global.player_position


#---------------------------------------------------------------------------------------------------------------------------
#Global shake function applied to camera from other scripts
func apply_camera_shake(shake_strength : float):
	shake_amount += shake_strength * SHAKE_MULTIPLIER


#---------------------------------------------------------------------------------------------------------------------------
#Get a random vector from positive to negative of the shake strength
func get_random_offset() -> Vector2: 
	return Vector2(
		randf_range(shake_amount, -shake_amount),
		randf_range(shake_amount, -shake_amount)
	)
