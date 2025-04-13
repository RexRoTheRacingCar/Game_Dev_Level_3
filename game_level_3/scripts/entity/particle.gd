############################## GPU Particle Class ##############################
extends GPUParticles2D

@export var death_time : float = 1.5

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	emitting = true
	
	await get_tree().create_timer(death_time, false).timeout
	
	queue_free()
