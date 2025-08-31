############################## Audio 2D Space Component ##############################
extends AudioStreamPlayer2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	pitch_scale += randf_range(0.1, -0.1)
	connect("finished", queue_free)
