############################## Ghost Enemy ##############################
extends Entity

@export_group("Ghost Enemy")
@export var speed : float = 250.0
var speed_mult : float = 1.0
var speed_mult_target : float = 1.0

@export var invisble_distance : float = 400.0
var alpha_target : float = 1.0
var is_invisible: bool = false
var invisible_timer : float = 0.0
var can_see_player : bool

@export var max_ammo : int = 4
var ammo : int = 4
@export var when_to_shoot : float = 2.5
var shoot_timer : float = 0.0

@onready var sprite = $Sprite2D
@onready var teleport_timer = $TeleportTimer
@onready var collision = $CollisionShape2D

const GHOST_BULLET = preload("res://scenes/entity/bullets/ghost_bullet.tscn")
const POP_PARTICLES = preload("res://scenes/entity/particles/bubble_pop2.tscn")
const GHOST_DEATH = preload("res://scenes/entity/particles/ghost_death.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	randomize()
	
	alpha_target = 1.0
	speed_mult = speed_mult_target
	ammo = max_ammo
	is_invisible = false
	
	invisible_timer = 0.0
	shoot_timer = when_to_shoot / 2
	
	hitbox_component.monitoring = true
	hurtbox_component.monitorable = true
	collision.disabled = false


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#Update can_see_player variable
	can_see_player = line_of_sight.target_check(Global.player_position - global_position, global_position)
	var distance = global_position.distance_to(Global.player_position)
	
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(Global.player_position, min_nav_time, max_nav_time)
		_move_enemy(delta)
		
		speed_mult = lerp(speed_mult, speed_mult_target, Global.weighted_lerp(24, delta))
		sprite.modulate = lerp(sprite.modulate, Color(1, 1, 1, alpha_target), Global.weighted_lerp(12, delta))
		health_component.modulate = sprite.modulate
	
	invisibility_and_shooting(delta, can_see_player, distance)


#---------------------------------------------------------------------------------------------------------------------------
func invisibility_and_shooting(delta : float, player_visible : bool, player_distance : float):
	#If enemy is visible
	if player_visible == true and player_distance < invisble_distance and is_invisible == false:
		shoot_timer += delta
		alpha_target = 1.0
		invisible_timer = 0.0
		
		#If ghost can shoot
		if shoot_timer > when_to_shoot:
			#Enough ammo
			if ammo > 0:
				_shoot_at_player(player_distance)
				shoot_timer = 0.0
				ammo -= 1
			#Not enough ammo (Teleports away)
			else:
				_invisible_setup()
	
	
	#If enemy is invisible
	if is_invisible == false and (player_distance > invisble_distance or player_visible == false):
		invisible_timer += delta
		alpha_target = 0.125
		
		#If out of range for a while
		if invisible_timer > 7.5 and player_distance > invisble_distance * 1.5:
			_invisible_setup()
			is_invisible = true
	
	if player_distance < invisble_distance * 1.05 or player_visible == true:
		hitbox_component.monitoring = true
	else:
		hitbox_component.monitoring = false


#---------------------------------------------------------------------------------------------------------------------------
#Ghost is teleporting
func _invisible_setup():
	is_invisible = true
	alpha_target = 0.0
	speed_mult_target = 0.0
	invisible_timer = 0.0
	
	hurtbox_component.monitorable = false
	collision.disabled = true
	
	var particle = spawn_scene(POP_PARTICLES, get_tree().root.get_node("/root/Game/"))
	particle.global_position = global_position
	particle.modulate = Color(1, 1, 1, 1)
	
	teleport_timer.start(1.0)


#---------------------------------------------------------------------------------------------------------------------------
#Ghost has teleported
func _on_teleport_timer_timeout():
	ammo = max_ammo
	global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	
	await get_tree().create_timer(1.0, false).timeout
	
	speed_mult_target = 1.0
	alpha_target = 1.0
	invisible_timer = 0.0
	is_invisible = false
	
	hurtbox_component.monitorable = true
	collision.disabled = false
	
	var particle = spawn_scene(POP_PARTICLES, get_tree().root.get_node("/root/Game/"))
	particle.global_position = global_position
	particle.modulate = Color(1, 1, 1, 1)


#---------------------------------------------------------------------------------------------------------------------------
func _move_enemy(delta : float):
	if can_navigate == true:
		#Navigate to player
		velocity = lerp(Vector2(
			velocity.x, velocity.y * 2), 
			current_agent_position.direction_to(next_path_position) * speed * speed_mult, Global.weighted_lerp(8, delta)
			)
		
		velocity.y /= 2
		velocity += knockback_taken
		knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
		move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func _shoot_at_player(distance : float): 
	#Find bullet angle
	var offset : Vector2 = Global.player_position - global_position
	offset = Vector2(offset.x, offset.y * 2)
	var dir = get_angle_to(Global.player_position + offset + Global.player_velocity * (distance / 650))
	
	#Bullet Wave
	for bullet in range(-3, 4):
		var bullet_float = float(bullet)
		var new_bullet = GHOST_BULLET.instantiate()
		
		#Apply variables to newly instanced bullet
		new_bullet.rotation = dir
		new_bullet.angle = bullet_float / 1.25
		new_bullet.initial_speed -= 60 * (bullet_float ** 2)
		var bullet_scale : float  =((-bullet_float ** 2) / 20) + 0.85
		new_bullet.scale = Vector2(bullet_scale, bullet_scale)
		new_bullet.global_position = global_position
		
		#Add bullet to tree
		get_tree().root.get_node("/root/Game/").add_child(new_bullet)
		
		new_bullet.implement_stats()
		new_bullet.death_timer_node.start(3.0)
	
	#Weapon recoil
	knockback_taken = Vector2.RIGHT.rotated(dir) * -125


#---------------------------------------------------------------------------------------------------------------------------
func hit_signalled(hurtbox : HurtboxComponent):
	super.hit_signalled(hurtbox)
	sprite.modulate = Color(1, 1, 1, 1)


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	
	var ghost_death = spawn_scene(GHOST_DEATH, get_tree().root.get_node("/root/Game/"))
	ghost_death.global_position = global_position / ghost_death.scale
	
	queue_free()
