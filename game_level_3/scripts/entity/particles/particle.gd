############################## GPU Particle Class ##############################
extends GPUParticles2D

@export var shake_on_start : float = 0.0
@onready var visible_rect = $VisibleOnScreenNotifier2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	emitting = false
	
	self.connect("finished", queue_free)
	Global.connect("room_changed", queue_free)
	Global.connect("reset_to_lobby", queue_free)
	
	visible_rect.rect = visibility_rect
	visible_rect.visible = false
	visible_rect.connect("screen_exited", queue_free)
	
	if global_position == Vector2.ZERO:
		queue_free()
	
	if shake_on_start != 0.0:
		Camera.apply_camera_shake(shake_on_start)
	
	if GlobalSettings.limited_particles == true:
		amount = int(round(float(amount) / 2))
	
	await get_tree().process_frame
	
	emitting = true
	visible_rect.visible = true
