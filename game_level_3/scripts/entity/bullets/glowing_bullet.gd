############################## Glowing Bullet ##############################
extends Bullet

var timer : float = 0.0

const POP_PARTICLES = preload("res://scenes/entity/particles/bubble_pop2.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	self.connect("delete_bullet_signal", _bullet_death)
	
	set_physics_process(false)
	super._ready()
	set_physics_process(true)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	super._physics_process(delta)
	_lerp_speed(delta)
	
	timer += delta
	sprite.rotation = timer * 4
	var sin_scale = (0.03 * sin(timer * 24)) + 0.29
	sprite.scale = Vector2(sin_scale, sin_scale)


#---------------------------------------------------------------------------------------------------------------------------
func actually_hit():
	super.actually_hit()


#---------------------------------------------------------------------------------------------------------------------------
func _bullet_death():
	var pop_scene = _new_scene(POP_PARTICLES)
	pop_scene.global_position = global_position
	
	queue_free()
