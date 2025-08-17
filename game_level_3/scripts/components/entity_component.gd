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
@export var min_nav_time : float = 0.3
@export var max_nav_time : float = 0.7
var can_navigate : bool = false
var current_agent_position : Vector2
var next_path_position

#Line of sight variables
@export var area_of_sight : AreaOfSight #Polygon / 2d Shape
@export var line_of_sight : LineOfSight #Raycast
var los_check : bool = false


#Knockback variables
@export_group("Misc")
@export var knockback_resistance : float = 1.0
var knockback_taken := Vector2.ZERO

@export var shake_on_hit : float = 5.5
@export var shake_on_death : float = 7.0

#Coin variables
@export var coin_min : int = 1
@export var coin_max : int = 3
const COIN_SCENE : PackedScene = preload("res://scenes/entity/coin.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	Global.enemy_count += 1
	Global.active_enemy_array.append(self)
	
	Global.connect("reset_to_lobby", queue_free)
	
	can_navigate = false
	current_agent_position = global_position
	next_path_position = navigation_agent.get_next_path_position()
	navigation_agent.target_position = Global.player_position
	knockback_taken = Vector2(0, 0)
	
	#Signals
	hitbox_component.hitbox_entered.connect(hit_signalled)
	health_component.zero_health.connect(no_health)
	self.connect("tree_exiting", queue_freeing)


#---------------------------------------------------------------------------------------------------------------------------
#Hit signal function
func hit_signalled(hurtbox: HurtboxComponent):
	if hurtbox != self.hurtbox_component:
		health_component.health -= hurtbox.hurt_damage
		hitbox_component.hit_timer.start(hitbox_component.hit_delay)
		
		#Apply camera shake and hit flash animations
		Camera.apply_camera_shake(shake_on_hit)
		if hit_flash_anim:
			hit_flash_anim.play("hit_flash")
		
		#Apply knockback to enemy
		if hurtbox.knockback_type == "center":
			var angle := get_angle_to(hurtbox.global_position) + PI
			knockback_taken = Vector2.RIGHT.rotated(angle)
		elif hurtbox.knockback_type == "velocity":
			knockback_taken = hurtbox.get_parent().velocity.normalized()
		else:
			knockback_taken = Vector2.ZERO
		
		knockback_taken *= hurtbox.hurt_knockback
		knockback_taken *= knockback_resistance


#---------------------------------------------------------------------------------------------------------------------------
#Spawn in a scene from entity parameters
func spawn_scene(scene : PackedScene, parent : Node):
	var new_scene = scene.instantiate()
	parent.call_deferred("add_child", new_scene)
	return new_scene


#---------------------------------------------------------------------------------------------------------------------------
#Navigation functions
func _navigation_check(target_pos : Vector2, timer_min : float, timer_max : float):
	if navigation_agent.is_navigation_finished():
		navigation_agent.target_position = target_pos
		return
	
	#Update navigation on timer
	if can_navigate == false:
		navigation_agent.target_position = target_pos
		
		current_agent_position = global_position
		next_path_position = navigation_agent.get_next_path_position()
		
		can_navigate = true
		var distance_to_target : float = global_position.distance_to(target_pos)
		var max_timer_distance : float = clampf(timer_max + ((distance_to_target ** 2) / 1500000), timer_min, 6.0)
		nav_timer.start(randf_range(timer_min, max_timer_distance))


#---------------------------------------------------------------------------------------------------------------------------
func _on_navigation_timer_timeout():
	can_navigate = false


#---------------------------------------------------------------------------------------------------------------------------
#Enemy has 0 HP
func no_health():
	var rand = randi_range(coin_min, coin_max)
	for _n in range(0, rand): #Spawn coins at death position
		var new_coin = spawn_scene(COIN_SCENE, get_tree().root.get_node("/root/Game/"))
		var rand_spawn : float = 30.0
		new_coin.global_position = Vector2(
			global_position.x + randf_range(rand_spawn, -rand_spawn), 
			global_position.y + randf_range(rand_spawn / 2, -rand_spawn / 2)
			)
	
	Camera.apply_camera_shake(shake_on_death)


#---------------------------------------------------------------------------------------------------------------------------
func queue_freeing():
	Global.enemy_count -= 1
	Global.active_enemy_array.erase(self)
