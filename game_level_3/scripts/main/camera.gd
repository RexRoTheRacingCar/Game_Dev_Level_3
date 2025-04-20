############################## Global Camera ##############################
extends Camera2D


#Camera shake variables
const shake_fade_rate : float = 0.4
const shake_multiplier : float = 1.0
const max_shake : float = 35.0
var shake_amount : float = 0.0


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	offset = Vector2.ZERO
	zoom = Vector2(2, 2)
	
	shake_amount = 0


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	#Camera shake
	shake_amount = clamp(lerp(shake_amount, 0.0, shake_fade_rate), 0.0, max_shake * shake_multiplier)
	offset = lerp(offset, get_random_offset(), 0.875)
	
	global_position = Global.player_position


#---------------------------------------------------------------------------------------------------------------------------
#Global shake function applied to camera from other scripts
func apply_camera_shake(shake_strength : float):
	shake_amount += shake_strength * shake_multiplier


#---------------------------------------------------------------------------------------------------------------------------
#Get a random vector from positive to negative of the shake strength
func get_random_offset() -> Vector2: 
	return Vector2(
		randf_range(shake_amount, -shake_amount),
		randf_range(shake_amount, -shake_amount)
	)
