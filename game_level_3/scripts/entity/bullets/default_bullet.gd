############################## Default Bullet ##############################
extends Bullet


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
	queue_free()
