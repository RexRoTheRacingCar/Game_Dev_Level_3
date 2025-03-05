############################## Bullet ##############################
extends CharacterBody2D
class_name Bullet


@export var hurtbox : HurtboxComponent

@export var speed := 600
@export var damage := 5.0
@export var max_pierce := 1

var current_pierce_count := 0
var fake_velocity = Vector2.ZERO


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	if hurtbox:
		hurtbox.hit_enemy.connect(on_enemy_hit)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var dir = Vector2.RIGHT.rotated(rotation)
	
	fake_velocity = dir * speed
	velocity = Vector2(fake_velocity.x, fake_velocity.y / 2) #Make velocity isometric
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		delete_bullet()


#---------------------------------------------------------------------------------------------------------------------------
func on_enemy_hit():
	current_pierce_count += 1
	
	if current_pierce_count >= max_pierce:
		delete_bullet()


#---------------------------------------------------------------------------------------------------------------------------
func delete_bullet():
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "speed", Vector2(100, 200), 1)
	queue_free()
