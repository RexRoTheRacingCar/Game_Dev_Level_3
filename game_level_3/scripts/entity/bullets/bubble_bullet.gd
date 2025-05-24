############################## Default Bullet ##############################
extends Bullet

var speed_rand : float = 0.0
var scale_rand : float = 0.0

const BUBBLE_POP_1 = preload("res://scenes/entity/particles/bubble_pop1.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	self.connect("delete_bullet_signal", _bullet_death)
	
	randomize()
	scale_rand = randf_range(0.5, 0.3)
	
	default_lifetime -= randf_range(0.0, 0.35)
	initial_speed *= randf_range(1.0, 0.8)
	
	scale = Vector2(
		scale_rand,
		scale_rand
	)
	
	set_physics_process(false)
	super._ready()
	set_physics_process(true)
	
	#Bullet death animation
	await get_tree().create_timer(default_lifetime / 2, false).timeout
	
	var delete_tween = create_tween()
	delete_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	delete_tween.tween_property(self, "scale", Vector2(0, 0), default_lifetime / 2).from_current()


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	super._physics_process(delta)
	_lerp_speed()


#---------------------------------------------------------------------------------------------------------------------------
func _bullet_death():
	#Bubble particles on queue_free()
	var bubbles = _new_scene(BUBBLE_POP_1)
	bubbles.global_position = global_position
	bubbles.scale = Vector2(scale_rand + 0.3, scale_rand + 0.3)
	
	queue_free()
