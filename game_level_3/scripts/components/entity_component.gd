############################## Entity Class ##############################
extends CharacterBody2D
class_name Entity

#Hitboxes & the like
@export_group("Main Nodes")
@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent
@export var hit_flash_anim : AnimationPlayer


#Naviagtion
@export_group("Navigation")
@export var navigation_agent : NavigationAgent2D
@export var nav_timer : Timer
var can_navigate : bool = false
var current_agent_position : Vector2
var next_path_position

#Area of sight variable
@export var area_of_sight : AreaOfSight

#Knockback variables
@export_group("Misc")
@export var knockback_resistance : float = 1.0
var knockback_taken := Vector2.ZERO

@export var shake_on_hit : float = 5.5

#Coin variables
@export var coin_range : int = 5
var coin_scene : PackedScene = preload("res://scenes/entity/coin.tscn")



#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	can_navigate = false
	current_agent_position = global_position
	next_path_position = navigation_agent.get_next_path_position()
	navigation_agent.target_position = Global.player_position
	
	#Signals
	hitbox_component.hitbox_entered.connect(hit_signalled)
	health_component.zero_health.connect(no_health)


#---------------------------------------------------------------------------------------------------------------------------
#Hit signal function
func hit_signalled(hurtbox: HurtboxComponent):
	health_component.health -= hurtbox.hurt_damage
	hitbox_component.hit_timer.start(hitbox_component.hit_delay)
	
	Camera.apply_camera_shake(shake_on_hit)
	if hit_flash_anim:
		hit_flash_anim.play("hit_flash")
	
	#Apply knockback to enemy
	knockback_taken = hurtbox.get_parent().velocity.normalized()
	knockback_taken *= hurtbox.hurt_knockback
	knockback_taken *= knockback_resistance
	
	#Knockback tweening to 0 for a slowdown effect
	var knockback_tweem := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	knockback_tweem.tween_property(self, "knockback_taken", Vector2.ZERO, 0.4)
	knockback_tweem.play()
	
	


#---------------------------------------------------------------------------------------------------------------------------
#Spawn in a scene from entity parameters
func spawn_scene(scene : PackedScene, parent : Node):
	var new_scene = scene.instantiate()
	parent.call_deferred("add_child", new_scene)
	return new_scene


#---------------------------------------------------------------------------------------------------------------------------
#Navigation functions
func _navigation_check(target_pos : Vector2, timer_min : float, timer_max : float):
	navigation_agent.target_position = target_pos
	if navigation_agent.is_navigation_finished():
		return
	
	#Update navigation on timer
	if can_navigate == false:
		current_agent_position = global_position
		next_path_position = navigation_agent.get_next_path_position()
		
		can_navigate = true
		nav_timer.start(randf_range(timer_min, timer_max))


#---------------------------------------------------------------------------------------------------------------------------
func _on_navigation_timer_timeout():
	can_navigate = false


#---------------------------------------------------------------------------------------------------------------------------
#Enemy has 0 HP
func no_health():
	for _n in randi_range(0, coin_range): #Spawn coins at death position
		var new_coin = spawn_scene(coin_scene, self.get_parent())
		var rand_spawn : float = 30.0
		new_coin.global_position = Vector2(
			global_position.x + randf_range(rand_spawn, -rand_spawn), 
			global_position.y + randf_range(rand_spawn / 2, -rand_spawn / 2)
			)
	
	Camera.apply_camera_shake(shake_on_hit * 1.35)
	
	queue_free()
