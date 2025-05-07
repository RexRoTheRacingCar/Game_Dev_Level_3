############################## Default Bullet ##############################
extends Bullet

var rand := 0.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	rand = randf_range(4.0, -4.0)
	
	set_physics_process(false)
	super._ready()
	set_physics_process(true)
	
	


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	super._physics_process(delta)
	_lerp_speed()
	
	rotation += rand * delta
