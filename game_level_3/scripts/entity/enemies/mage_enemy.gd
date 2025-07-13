############################## Mage Enemy ##############################
extends Entity

@export var speed : float = 150.0
var max_speed : float = 150.0
var circling_directon : float = 1.0
var move_timer : float = 0.0

@export_group("Special Variables")
#Special Timing
@export var special_min : float = 12.0
@export var special_max : float = 16.0
var selected_time : float = 0.0
var special_timer : float = 0.0

@export var special_distance : float = 300.0
var special_active : bool

const WEAK_ENEMY = preload("res://scenes/entity/enemy/weak_enemy.tscn")
const EXPLOSION = preload("res://scenes/entity/secondaries/explosion.tscn")
const DUST_SCENE = preload("res://scenes/entity/particles/dust_splash1.tscn")
const TELEPORT_SCENE = preload("res://scenes/entity/particles/teleport_scene.tscn")

@onready var sprite = $Sprite2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	max_speed = speed
	selected_time = randf_range(special_min, special_max)
	special_active = false
	
	sprite.texture.region = Rect2(0, 0, 100, 100)
	
	if randf() >= 0.5: circling_directon = -1.0


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	special_timer += delta
	var dis : float = global_position.distance_to(Global.player_position)
	if dis < 360 and dis > 100:
		move_timer += delta / 5.0
		if move_timer > 4.0:
			move_timer = 0
			circling_directon *= -1.05
	else:
		move_timer = 0
	
	if special_timer >= selected_time and special_active == false:
		special_timer = 0.0
		_special_move(delta)
	
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		#Circling the player navigation
		if special_active == false:
			#Pathfind around the player in an orbit
			var target_angle : float = Global.player_position.angle_to_point(global_position)
			var target_location : Vector2 = Vector2.RIGHT.rotated((2 * PI * circling_directon) + target_angle + move_timer) * 350
			target_location = Global.player_position + Vector2(target_location.x, target_location.y / 2) 
			target_location = Global.get_nav_mesh_point(Global.global_map, target_location, 5)
			_navigation_check(target_location, min_nav_time, max_nav_time)
		
		if can_navigate == true:
			#Navigate to player
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, Global.weighted_lerp(8, delta)
				)
			
			velocity.y /= 2
			velocity += knockback_taken
			knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
			move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func _special_move(_delta : float):
	var distance = global_position.distance_to(Global.player_position)
	special_timer = 0.0
	special_active = true
	
	var TWEEN_TIME := 0.6
	
	#Pre-special animations
	var tween_1 = create_tween()
	tween_1.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).set_parallel(true)
	tween_1.tween_property(self, "speed", 0, TWEEN_TIME).from_current()
	
	await get_tree().create_timer(TWEEN_TIME, false).timeout
	
	@warning_ignore("integer_division")
	if randf() >= 0.5 and (distance >= special_distance or (distance <= special_distance and health_component.health <= health_component.max_health / 2)):
		#TELEPORT PREP
		var new_pos : Vector2 = Global.rand_nav_mesh_point(Global.global_map, 2, false)
		var teleport_1 = spawn_scene(TELEPORT_SCENE, get_tree().root.get_node("/root/Game/"))
		teleport_1.global_position = global_position
		teleport_1.modulate = Color(0.108, 0.83, 0.637)
		var teleport_2 = spawn_scene(TELEPORT_SCENE, get_tree().root.get_node("/root/Game/"))
		teleport_2.global_position = new_pos
		teleport_2.modulate = Color(0.108, 0.83, 0.637)
		
		sprite.texture.region = Rect2(200, 0, 100, 100)
		
		var sprite_tween_1 = create_tween()
		sprite_tween_1.tween_property(sprite, "modulate", Color(0, 0.6, 0.45), TWEEN_TIME / 2).from_current()
		hurtbox_component.set_collision_layer_value(2, false)
		
		await get_tree().create_timer(TWEEN_TIME, false).timeout
		
		#THE TELEPORT & EXPLOSION
		var old_pos : Vector2 = global_position
		global_position = new_pos
		_spawn_magic_explosion(old_pos, false)
		_spawn_magic_explosion(new_pos, false)
	
	else:
		#SUMMON PREP
		sprite.texture.region = Rect2(100, 0, 100, 100)
		
		var sprite_tween_1 = create_tween()
		sprite_tween_1.tween_property(sprite, "modulate", Color(0.75, 0.45, 0), TWEEN_TIME / 2).from_current()
		var summon_effect = spawn_scene(TELEPORT_SCENE, get_tree().root.get_node("/root/Game/"))
		summon_effect.global_position = global_position
		summon_effect.modulate = Color(0.83, 0.409, 0.108)
		
		#SUMMON
		await get_tree().create_timer(TWEEN_TIME, false).timeout
		enemy_summon()
	
	#Post special animations
	var sprite_tween_2 = create_tween()
	sprite_tween_2.tween_property(sprite, "modulate", Color(1, 1, 1), TWEEN_TIME / 2).from_current()
	
	await get_tree().create_timer(TWEEN_TIME, false).timeout
	sprite.texture.region = Rect2(0, 0, 100, 100)
	await get_tree().create_timer(TWEEN_TIME / 2, false).timeout
	
	#Speed
	var tween_2 = create_tween()
	tween_2.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN).set_parallel(true)
	tween_2.tween_property(self, "speed", max_speed, TWEEN_TIME).from_current()
	hurtbox_component.set_collision_layer_value(2, true)
	
	special_active = false


#---------------------------------------------------------------------------------------------------------------------------
func enemy_summon():
	#Summon Enemies
	var amt : int = 4
	var rand = randf() * 2 * PI

	for enemy in range(0, amt):
		var target : Vector2 = Vector2.RIGHT.rotated((((2 * PI) / amt) * enemy) + rand) * 75
		target = global_position + Vector2(target.x, target.y / 2)
		var spawn_pos = Global.get_nav_mesh_point(Global.global_map, target, 16.0)
		#Enemy
		var new_enemy = spawn_scene(WEAK_ENEMY, get_tree().root.get_node("/root/Game/"))
		new_enemy.global_position = spawn_pos
		#Dust
		var new_dust = spawn_scene(DUST_SCENE, get_tree().root.get_node("/root/Game/"))
		new_dust.global_position = new_enemy.global_position
		new_dust.modulate = Color(1, 0, 0)


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_magic_explosion(pos : Vector2, damage : bool):
	var new_explosion = spawn_scene(EXPLOSION, get_tree().root.get_node("/root/Game/"))
	new_explosion.global_position = pos
	new_explosion.power_mult = 0.7
	new_explosion.modulate = Color(0.13, 1.0, 0.54)
	new_explosion.anim_player.speed_scale = 0.35
	if damage == false:
		new_explosion.hurtbox.set_collision_layer_value(2, false)
		new_explosion.hurtbox.set_collision_layer_value(4, false)
	
	return new_explosion


#---------------------------------------------------------------------------------------------------------------------------
func hit_signalled(hurtbox : HurtboxComponent):
	super.hit_signalled(hurtbox)
	special_timer += 4.5


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	
	_spawn_magic_explosion(global_position, true)
	
	queue_free()
