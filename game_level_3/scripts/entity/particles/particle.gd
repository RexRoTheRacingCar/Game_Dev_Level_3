############################## GPU Particle Class ##############################
extends GPUParticles2D

@export var shake_on_start : float = 0.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	emitting = true
	self.connect("finished", _on_finished)
	
	if shake_on_start != 0.0:
		Camera.apply_camera_shake(shake_on_start)


#---------------------------------------------------------------------------------------------------------------------------
func _on_finished():
	queue_free()
