############################## Bullet Class ##############################
extends CharacterBody2D
class_name Bullet


@export_group("Bullet Nodes")
@export var hurtbox : HurtboxComponent
@export var death_timer_node : Timer
@export var collision_timer_node : Timer
@export var sprite : Node2D
@export var particle : GPUParticles2D

@export_group("Bullet Stats")
@export var default_damage : int = 5
@export var default_lifetime : float = 0.5
@export var default_knockback : float = 20

@export var initial_speed : float = 950.0
@export var target_speed : float = 950.0
@export var lerp_speed : float = 1.0

@export var accuracy : float = 0.125
@export var collision_time : float = 0.15
@export var max_pierce : int = 1

@export var can_skew : bool = true

var damage : int
var lifetime : float
var knockback : float
var speed : float = 0.0

var current_pierce_count := 0
var rotation_offset : float = 0.0
var fake_velocity : Vector2 = Vector2.ZERO
var collide_array : Array = []
var collision_hit : bool = false


#Signal used in other bullet scripts
@warning_ignore("unused_signal")
signal delete_bullet_signal


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	visible = false
	collide_array.clear()
	current_pierce_count = 1
	collision_hit = false
	speed = initial_speed
	
	if hurtbox:
		hurtbox.monitorable = true
		hurtbox.monitoring = false
	
	_load_starter_values()
	
	call_deferred("_update_bullet")
	
	if particle:
		particle.emitting = !GlobalSettings.limited_particles
	
	#Stop bullet collding with walls
	if hurtbox: 
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		hurtbox.monitoring = true



#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float):
	velocity = _bullet_velocity()
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _load_starter_values():
	damage = default_damage
	lifetime = default_lifetime
	knockback = default_knockback


#---------------------------------------------------------------------------------------------------------------------------
func _bullet_velocity() -> Vector2:
	fake_velocity = Vector2.RIGHT.rotated(rotation) * speed 
	return Vector2(
		fake_velocity.x, 
		fake_velocity.y / 2
		)


#---------------------------------------------------------------------------------------------------------------------------
func _lerp_speed(delta : float):
	speed = lerp(speed, target_speed, Global.weighted_lerp(lerp_speed, delta))


#---------------------------------------------------------------------------------------------------------------------------
func _update_bullet():
	visible = true
	rotation_offset = randf_range(accuracy, -accuracy)
	rotation += rotation_offset
	
	velocity = _bullet_velocity()
	
	if sprite:
		sprite.rotation = velocity.angle() - rotation
		if can_skew ==  true: 
			sprite.skew = (0.5 * sin((2 * PI) * (sprite.rotation)) + 0)
	if hurtbox:
		hurtbox.hurtbox_hit.connect(on_enemy_hit)
		hurtbox.hurtbox_exited.connect(enemy_un_hit)



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
	hurtbox.hurt_knockback = knockback


#---------------------------------------------------------------------------------------------------------------------------
func delete_bullet():
	if particle:
		particle.emitting = false
	
	#Stop lingering hitboxes
	if hurtbox:
		hurtbox.set_deferred("monitorable", false)
	
	emit_signal("delete_bullet_signal")


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


#---------------------------------------------------------------------------------------------------------------------------
func _new_scene(scene : PackedScene):
	var new_scene = scene.instantiate()
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_scene)
	return new_scene
