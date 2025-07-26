############################## Ghost Bullet ##############################
extends Bullet

var angle : float = 0.0

const POP_PARTICLES = preload("res://scenes/entity/particles/bubble_pop2.tscn")
@onready var line = $Line2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	self.connect("delete_bullet_signal", _bullet_death)
	
	set_physics_process(false)
	super._ready()
	set_physics_process(true)
	
	line.twirl_amplitude = randf_range(-16, 16)
	line.twirl_freq = randf_range(4.0, 12.0)
	
	var scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN).set_parallel(false)
	scale_tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 3.0).from_current()

#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	super._physics_process(delta)
	_lerp_speed(delta)
	
	rotation += angle * delta


#---------------------------------------------------------------------------------------------------------------------------
func actually_hit():
	super.actually_hit()


#---------------------------------------------------------------------------------------------------------------------------
func _bullet_death():
	var pop_scene = _new_scene(POP_PARTICLES)
	pop_scene.global_position = global_position
	pop_scene.modulate = Color(0.63, 0.988, 1.0)
	
	queue_free()
