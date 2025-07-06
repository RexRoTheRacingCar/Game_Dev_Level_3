############################## Turret Secondary ##############################
extends BaseSecondary

@onready var range_area = %RangeArea
var target_array : Array = []
var target : Entity

@onready var death_timer = %DeathTimer
@export var can_shoot : bool = false
@export var shoot_time : float = 1.0
var timer : float = 0.0

const BULLET = preload("res://scenes/entity/bullets/default_bullet.tscn")
const LANDING_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")
const DUST_SCENE = preload("res://scenes/entity/particles/dust_splash1.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	global_position = Global.get_nav_mesh_point(Global.global_map, global_position, 10)
	
	target_array = []
	
	range_area.connect("body_entered", body_entered)
	range_area.connect("body_exited", body_exited)
	death_timer.connect("timeout", turret_death)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	if target_array.is_empty() == false:
		timer += delta
		
		#Shoot when timer says so, reset timer afterwards
		if timer >= shoot_time / ((power_mult + 1.0) / 2) and can_shoot == true:
			timer = 0.0
			_shoot_bullet()


#---------------------------------------------------------------------------------------------------------------------------
#Check if target exists, return bool
func _check_target_array():
	for enemy in range(0, target_array.size() - 1):
		if is_instance_valid(target_array[enemy]) == false:
			target_array.erase(enemy)
	
	if target_array.is_empty() == false:
		return true
	return false


#---------------------------------------------------------------------------------------------------------------------------
func _shoot_bullet():
	#Check for target
	if _check_target_array() == false:
		return
	
	#Find closest enemy to turret
	var aim_target : Entity
	var enemy_dist : float = 99999.9
	
	for enemy in range(0, target_array.size()):
		var dist = global_position.distance_to(target_array[enemy].global_position)
		if dist < enemy_dist:
			enemy_dist = dist
			aim_target = target_array[enemy]
	
	#Instance bullet & aim at target. Predictive aiming. 
	var new_bullet := BULLET.instantiate()
	var vel : Vector2 = aim_target.velocity
	var offset : Vector2 = aim_target.global_position - global_position
	offset = Vector2(offset.x, offset.y * 2)
	var dist_to_enemy : float = global_position.distance_to(aim_target.global_position)
	var dir = get_angle_to(aim_target.global_position + offset + vel * (dist_to_enemy / (new_bullet.initial_speed * 0.8)))
	
	#Bullet spawned
	new_bullet.global_position = global_position
	new_bullet.rotation = dir
	new_bullet.accuracy /= 2
	
	new_bullet.damage *= power_mult
	
	get_tree().root.get_node("/root/Game/").add_child(new_bullet)
	
	new_bullet.implement_stats()
	new_bullet.death_timer_node.start(new_bullet.lifetime * 1.6)


#When death timer runs out, delete turret
#---------------------------------------------------------------------------------------------------------------------------
func turret_death():
	crash_landed()
	queue_free()


#Turret has landed
#---------------------------------------------------------------------------------------------------------------------------
func crash_landed():
	#Particle effects
	var landing_particle = Global.spawn_particle(global_position, self, LANDING_PULSE)
	landing_particle.scale *= 2
	Global.spawn_particle(global_position, self, DUST_SCENE)


#Enter & exit range
#---------------------------------------------------------------------------------------------------------------------------
func body_entered(body : Entity):
	target_array.append(body)


#---------------------------------------------------------------------------------------------------------------------------
func body_exited(body : Entity):
	target_array.erase(body)
