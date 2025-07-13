############################## Bomber Enemy ##############################
extends Entity

@export var MAX_SPEED : float = 375.0
var speed : float = 425.0
var target_speed : float = 425.0
var target_pos : Vector2

const FLYING_BOMB = preload("res://scenes/entity/bullets/flying_bomb.tscn")
const WARNING_OUTLINE = preload("res://scenes/entity/warning_outline.tscn")
const SMALL_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")
const EXPLOSION = preload("res://scenes/entity/secondaries/explosion.tscn")

var timer : float = 0.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	target_pos = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	can_navigate = false
	
	timer = randf_range(3.0, -2.0)
	target_speed = MAX_SPEED
	speed = MAX_SPEED


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#If Area Of Sight returns with a target
	timer += delta
	if area_of_sight.target != null:
		speed = lerpf(speed, target_speed, 0.075)
		
		if global_position.distance_to(target_pos) <= 50.0:
			target_pos = Global.rand_nav_mesh_point(Global.global_map, 2, false)
			can_navigate = false
		
		_navigation_check(target_pos, min_nav_time, max_nav_time)
		
		if can_navigate == true:
			#Navigate to random point
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, Global.weighted_lerp(9, delta)
				)
			
			velocity.y /= 2
			velocity += knockback_taken
			knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
			move_and_slide()
	
		if timer >= 5.0:
			target_speed = 0.0
			
			timer = randf_range(-2.0, -8.0)
			
			await get_tree().create_timer(randf_range(0.6, 1.6), false).timeout
			
			for _bomb in randi_range(1, 3):
				_create_bomb(delta)
				await get_tree().create_timer(randf_range(0.1, 0.6), false).timeout
			
			await get_tree().create_timer(randf_range(0.4, 1.4), false).timeout
			
			target_speed = MAX_SPEED


#---------------------------------------------------------------------------------------------------------------------------
#Create and load in variables to create a lobbing bomb
func _create_bomb(_delta : float):
	#Particle effect
	var pulse_scene = spawn_scene(SMALL_PULSE, self)
	pulse_scene.modulate = Color(1, 1, 1, 0.675)
	pulse_scene.scale = Vector2(1.8, 0.9)
	
	var new_bomb = FLYING_BOMB.instantiate()
	#Bomb positioning
	new_bomb.spawn_pos = global_position
	new_bomb.target_pos = Global.player_position
	new_bomb.warning_scene = WARNING_OUTLINE
	new_bomb.explosion_scene = EXPLOSION
	#Bomb airtime
	new_bomb.air_time = global_position.distance_to(new_bomb.target_pos) / 400
	new_bomb.air_time = clamp(new_bomb.air_time, 1.0, 3.5)
	new_bomb.warning_time = new_bomb.air_time / 4
	#Bomb scale
	var rand_scale = randf_range(1.5, 2.0)
	new_bomb.explosion_scale = Vector2(rand_scale, rand_scale / 2)
	
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_bomb)


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()
