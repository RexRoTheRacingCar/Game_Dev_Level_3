############################## Bullet ##############################
extends CharacterBody2D
class_name Bullet


@export var hurtbox : HurtboxComponent
@export var collision : CollisionShape2D

@export var speed := 600
@export var damage := 5.0
@export var max_pierce := 1

var current_pierce_count := 0
var fake_velocity := Vector2.ZERO
var has_collided : bool = false


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	has_collided = false
	collision.disabled = false
	
	if hurtbox:
		hurtbox.hit_enemy.connect(on_enemy_hit)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var dir = Vector2.RIGHT.rotated(rotation)
	
	fake_velocity = dir * speed
	velocity = Vector2(fake_velocity.x, fake_velocity.y / 2) #Make velocity isometric
	
	if has_collided == false:
		var if_collision := move_and_collide(velocity * delta)
		
		if if_collision:
			delete_bullet()
	else:
		move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func on_enemy_hit():
	current_pierce_count += 1
	
	if current_pierce_count >= max_pierce:
		delete_bullet()


#---------------------------------------------------------------------------------------------------------------------------
func delete_bullet():
	has_collided = true
	collision.disabled = true
	speed *= -1
	
	var delete_tween = create_tween()
	delete_tween.tween_property(self, "speed", 0, 0.35).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN).from_current()
	
	await get_tree().create_timer(0.35, false).timeout
	
	queue_free()
