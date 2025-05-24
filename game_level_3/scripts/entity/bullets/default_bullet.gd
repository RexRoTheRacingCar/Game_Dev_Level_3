############################## Default Bullet ##############################
extends Bullet

const SMALL_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	self.connect("delete_bullet_signal", _bullet_death)
	
	set_physics_process(false)
	super._ready()
	set_physics_process(true)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	super._physics_process(delta)


#---------------------------------------------------------------------------------------------------------------------------
func actually_hit():
	super.actually_hit()
	var bullet_pulse = _new_scene(SMALL_PULSE)
	bullet_pulse.global_position = global_position


#---------------------------------------------------------------------------------------------------------------------------
func _bullet_death():
	#Bubble particles on queue_free()
	var bullet_pulse = _new_scene(SMALL_PULSE)
	bullet_pulse.global_position = global_position
	
	queue_free()
