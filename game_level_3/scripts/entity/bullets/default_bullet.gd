############################## Default Bullet ##############################
extends Bullet


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	set_physics_process(false)
	super._ready()
	set_physics_process(true)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	super._physics_process(delta)
