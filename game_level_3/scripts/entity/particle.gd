############################## GPU Particle Class ##############################
extends GPUParticles2D


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	emitting = true

#---------------------------------------------------------------------------------------------------------------------------
func _on_finished():
	queue_free()
