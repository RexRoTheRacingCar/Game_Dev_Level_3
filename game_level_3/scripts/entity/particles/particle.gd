############################## GPU Particle Class ##############################
extends GPUParticles2D

@export var shake_on_start : float = 0.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	emitting = true
	self.connect("finished", queue_free)
	Global.connect("room_changed", queue_free)
	
	if shake_on_start != 0.0:
		Camera.apply_camera_shake(shake_on_start)
	
	if GlobalSettings.limited_particles == true:
		amount = int(round(float(amount) / 2))
