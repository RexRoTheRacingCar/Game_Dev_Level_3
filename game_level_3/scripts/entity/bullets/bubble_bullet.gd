############################## Default Bullet ##############################
extends Bullet

var speed_rand : float = 0.0
var scale_rand : float = 0.0

@export var pop_bubble_scene = preload("res://scenes/entity/particles/bubble_pop1.tscn")


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	self.connect("delete_bullet_signal", _bullet_death)
	
	randomize()
	speed_rand = randf_range(3.5, -3.5)
	scale_rand = randf_range(0.8, 0.5)
	
	default_lifetime -= randf_range(0.0, 0.35)
	
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
	
	rotation += speed_rand * delta


#---------------------------------------------------------------------------------------------------------------------------
func _bullet_death():
	#Bubble particles on queue_free()
	var bubbles = _spawn_bubbles()
	bubbles.global_position = global_position
	bubbles.scale = Vector2(scale_rand + 0.2, scale_rand + 0.2)
	
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_bubbles():
	#Spawns bubble particle effects
	var new_scene = pop_bubble_scene.instantiate()
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_scene)
	return new_scene
