############################## Audio 2D Space Component ##############################
extends AudioStreamPlayer2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	pitch_scale += randf_range(0.15, -0.15)
	connect("finished", queue_free)
