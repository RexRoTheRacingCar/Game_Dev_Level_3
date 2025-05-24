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
func _bullet_death():
	#Bubble particles on queue_free()
	var bubbles = _new_scene(SMALL_PULSE)
	bubbles.global_position = global_position
	#bubbles.scale = Vector2(0.3, 0.3)
	
	queue_free()
