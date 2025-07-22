############################## Ranged Enemy ##############################
extends Entity

@export_group("Movement")
@export var pursuit_speed : float = 300.0
@export var fleeing_speed : float = 450.0
var speed : float = 250.0
var shoot_move_speed : float = 0.0

var orbit_distance : float = 425
var move_timer : float = 0.0
var circling_directon : float = 1.0

@export_group("Enemy Misc")
@export var shoot_speed : float = 2.0
var shoot_timer : float = 0.0

@onready var fleeing_particles = $FleeingParticles
var can_see_player : bool

enum {
	PURSUIT,
	IN_RANGE, 
	FLEEING
}
var state = PURSUIT

const GLOWING_BULLET = preload("res://scenes/entity/bullets/glowing_bullet.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	randomize()
	
	speed = 0
	shoot_move_speed = 0
	move_timer = 0
	shoot_timer = randf_range(0.0, shoot_speed / 2)
	orbit_distance = randf_range(275, 350)
	
	_rand_orbit()
	
	fleeing_particles.emitting = false
	state = PURSUIT


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#Update can_see_player variable
	can_see_player = line_of_sight.target_check(Global.player_position - global_position, global_position)
	var distance = global_position.distance_to(Global.player_position)
	
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		match state:
			PURSUIT: #Pursue the player
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				
				speed = lerp(speed, pursuit_speed, Global.weighted_lerp(10, delta))
				if can_see_player == true:
					shoot_timer += delta / 2
				
					#Check if enemy should switch states
					if distance < orbit_distance * 1.1:
						_rand_orbit()
						state = IN_RANGE
						move_timer = 0.0
			
			IN_RANGE: #Enemy is in_range with the player
				shoot_timer += delta
				move_timer += delta / 3.0
				
				#Pathfind around the player in an orbit
				var target_angle : float = Global.player_position.angle_to_point(global_position)
				var target_location : Vector2 = Vector2.RIGHT.rotated((2 * PI) + target_angle + (move_timer * circling_directon)) * orbit_distance
				target_location = Global.player_position + target_location
				target_location = Global.get_nav_mesh_point(Global.global_map, target_location, 5)
				_navigation_check(target_location, min_nav_time, max_nav_time)
				
				speed = lerp(speed, pursuit_speed / 1.2, Global.weighted_lerp(8, delta))
				
				#Check if enemy should switch states
				if distance < orbit_distance / 2 and can_see_player == true:
					fleeing_particles.emitting = true
					state = FLEEING
				
				if distance > orbit_distance * 1.3 or can_see_player == false:
					state = PURSUIT
			
			FLEEING: #Enemy is too close to the player
				shoot_timer += delta * 2.25
				speed = lerp(speed, fleeing_speed, Global.weighted_lerp(10, delta))
				
				var vec_dir : Vector2 = (global_position - Global.player_position).normalized()
				var target_location = global_position + vec_dir * 100
				_navigation_check(target_location, min_nav_time, max_nav_time)
				
				if distance > orbit_distance * 1.1:
					fleeing_particles.emitting = false
					state = PURSUIT
		
		_move_enemy(delta)
	
	#The enemy shoot timer + Line of Sight check
	if shoot_timer > shoot_speed and can_see_player == true:
		shoot_timer = 0.0
		_shoot_at_player(distance)
	
	if shoot_timer > shoot_speed - 0.4 and state == IN_RANGE:
		shoot_move_speed = lerp(shoot_move_speed, 0.0, Global.weighted_lerp(30, delta))
	else:
		shoot_move_speed = lerp(shoot_move_speed, 1.0, Global.weighted_lerp(30, delta))


#---------------------------------------------------------------------------------------------------------------------------
func _move_enemy(delta : float):
	if can_navigate == true:
		#Navigate to player
		velocity = lerp(Vector2(
			velocity.x, velocity.y * 2), 
			current_agent_position.direction_to(next_path_position) * speed * shoot_move_speed, Global.weighted_lerp(8, delta)
			)
		
		velocity.y /= 2
		velocity += knockback_taken
		knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
		move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func _shoot_at_player(distance : float): 
	#Find bullet angle
	var new_bullet = GLOWING_BULLET.instantiate()
	var offset : Vector2 = Global.player_position - global_position
	offset = Vector2(offset.x, offset.y * 2)
	var dir = get_angle_to(Global.player_position + offset + Global.player_velocity * (distance / (new_bullet.initial_speed * 0.8)))
	
	#Weapon recoil
	knockback_taken = Vector2.RIGHT.rotated(dir) * -100
	
	#Apply variables to newly instanced bullet
	new_bullet.accuracy /= 2
	new_bullet.rotation = dir
	new_bullet.global_position = global_position
	
	#Add bullet to tree
	get_tree().root.get_node("/root/Game/").add_child(new_bullet)
	
	new_bullet.implement_stats()
	new_bullet.death_timer_node.start(2.5)


#---------------------------------------------------------------------------------------------------------------------------
func _rand_orbit():
	circling_directon = randf_range(-1.0, 1.0)
	circling_directon = circling_directon / abs(circling_directon)


#---------------------------------------------------------------------------------------------------------------------------
func hit_signalled(hurtbox : HurtboxComponent):
	super.hit_signalled(hurtbox)
	shoot_timer /= 2.0


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()
