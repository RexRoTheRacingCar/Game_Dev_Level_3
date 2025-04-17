############################## Default Bullet ##############################
extends Bullet


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	set_physics_process(false)
	visible = false
	
	collide_array.clear()
	current_pierce_count = 1
	collision_hit = false
	if hurtbox:
		hurtbox.monitoring = false
	
	load_starter_values()
	
	await get_tree().create_timer(0.075, false).timeout
	
	call_deferred("update_bullet")
	set_physics_process(true)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float):
	velocity = _bullet_velocity()
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		queue_free()
