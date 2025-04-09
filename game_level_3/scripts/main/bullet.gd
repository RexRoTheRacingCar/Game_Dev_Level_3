############################## Bullet ##############################
extends CharacterBody2D
class_name Bullet


@export_group("Bullet Nodes")
@export var hurtbox : HurtboxComponent
@export var death_timer_node : Timer
@export var collision_timer_node : Timer
@export var sprite : Node2D


@export_group("Bullet Stats")
@export var speed : float = 650.0
@export var damage : int = 5
@export var max_pierce : int = 1
@export var life_time : float = 0.8
@export var collision_time : float = 0.15

var current_pierce_count := 0
var fake_velocity := Vector2.ZERO
var collide_array : Array = []
var collision_hit : bool = false


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	collide_array.clear()
	current_pierce_count = 1
	collision_hit = false
	
	if sprite:
		sprite.look_at(get_global_mouse_position())
	
	if hurtbox:
		hurtbox.hurtbox_hit.connect(on_enemy_hit)
		hurtbox.hurtbox_exited.connect(enemy_un_hit)
		hurtbox.monitoring = false
		await get_tree().create_timer(0.1, false).timeout
		hurtbox.monitoring = true


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var dir = Vector2.RIGHT.rotated(rotation)
	
	fake_velocity = dir * speed
	velocity = Vector2(fake_velocity.x, fake_velocity.y / 2) #Make velocity isometric
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func on_enemy_hit(body) -> void:
	if collide_array.find(body) == -1: 
		collide_array.append(body)
		_on_collision_timer_timeout()


#---------------------------------------------------------------------------------------------------------------------------
func enemy_un_hit(body) -> void:
	collide_array.erase(body)


#---------------------------------------------------------------------------------------------------------------------------
func actually_hit() -> void:
	if current_pierce_count >= max_pierce:
		delete_bullet()
	
	current_pierce_count += 1


#---------------------------------------------------------------------------------------------------------------------------
func implement_stats():
	hurtbox.hurt_damage = damage


#---------------------------------------------------------------------------------------------------------------------------
func delete_bullet():
	speed = 0
	
	#Bullet death animation
	var delete_tween = create_tween()
	delete_tween.tween_property(self, "scale", Vector2(0, 0), 0.35).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).from_current()
	
	await get_tree().create_timer(0.35, false).timeout
	
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
#Timer Nodes
func _on_delete_timer_timeout():
	delete_bullet()


func _on_collision_timer_timeout():
	collision_hit = false
	if collide_array.is_empty() == false and collision_hit == false:
		actually_hit()
		collision_timer_node.start(collision_time)
		collision_hit = true
