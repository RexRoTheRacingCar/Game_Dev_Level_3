############################## Line Component ##############################
extends Line2D

@export var length = 20 #Set trail length
var point = Vector2()

@export_group("Twirling")
@export var twirl_amplitude : float = 0.0
@export var twirl_freq : float = 0.0
var time : float = 0.0

@export var offset : Vector2 = Vector2.ZERO

#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	global_rotation = 0
	global_position = Vector2.ZERO
	
	time += delta
	
	var twirl_sine : float = twirl_amplitude * sin(time * twirl_freq)
	var twirl_cos : float = twirl_amplitude * cos(time * twirl_freq)
	var twirl_pos : Vector2 = Vector2(twirl_sine, twirl_cos / 2)
	add_point((get_parent().global_position / get_parent().scale) + twirl_pos + offset) #Add trail
	
	if points.size() > length: #Delete trail over certain length
		remove_point(0) 
