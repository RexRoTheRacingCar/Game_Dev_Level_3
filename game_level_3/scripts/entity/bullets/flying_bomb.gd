############################## Flying Bomb Projectile ##############################
extends Node2D

@export_group("Explosion Variables")
@export var spawn_pos : Vector2
@export var target_pos : Vector2
@export var air_time : float
@export var explosion_scene : PackedScene
@export var warning_scene : PackedScene
@export var warning_time : float
@export var explosion_scale : Vector2

@export_group("Misc")
@export var bomb_texture : Texture2D
@export var bomb_sprite_scale : Vector2

@onready var bomb_sprite = $BombSprite
@onready var bomb_shadow = $BombShadow
@onready var airbrone_particles = $BombSprite/AirbroneParticles

var distance : float
var rand_flip : float

const EXPLOSION_1_SFX = preload("res://assets/audio/diegetic_sfx/explosion_1.mp3")
const EXPLOSION_2_SFX = preload("res://assets/audio/diegetic_sfx/explosion_2.mp3")
const EXPLOSION_3_SFX = preload("res://assets/audio/diegetic_sfx/explosion_3.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.connect("room_changed", queue_free)
	Global.connect("reset_to_lobby", queue_free)
	
	#Go to start position
	global_position = spawn_pos
	distance = spawn_pos.distance_to(target_pos)
	
	#Bomb sprite & Particles
	bomb_sprite.z_index = 15
	if bomb_sprite_scale:
		bomb_sprite.scale = bomb_sprite_scale
	airbrone_particles.emitting = !GlobalSettings.limited_particles
	
	rand_flip = randf_range(-1.0, 1.0)
	bomb_sprite.rotation = rand_flip * 7
	rand_flip /= abs(rand_flip)
	
	var v : float = 5.0 #v for variation
	target_pos += Vector2(randf_range(distance / v, -distance / v), randf_range(distance / v, -distance / v) / 2)
	
	#Animate the explosion and await air_time
	var ground_tween = create_tween()
	ground_tween.tween_property(self, "global_position", target_pos, air_time).from(spawn_pos)
	
	var air_tween = create_tween()
	air_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_parallel(false)
	air_tween.tween_property(bomb_sprite, "position", Vector2(0, -(distance + 20.0) / 2), air_time / 2)
	air_tween.tween_property(bomb_sprite, "position", Vector2(0, 0), air_time / 2).set_ease(Tween.EASE_IN)
	
	await get_tree().create_timer(warning_time, false).timeout
	
	#Load warning scene (if any)
	if warning_scene:
		var new_scene = Global.spawn_particle(target_pos, self, warning_scene)
		new_scene.global_position = target_pos
		new_scene.scale = explosion_scale
		new_scene.get_child(0).speed_scale = 1 / (air_time - warning_time)
	
	await get_tree().create_timer(air_time - warning_time, false).timeout
	
	#Explode
	if explosion_scene:
		var new_explosion = Global.spawn_particle(target_pos, self, explosion_scene)
		new_explosion.scale = Vector2(explosion_scale.x, explosion_scale.y * 2) / 1.6
		
		var explosion_chance : float = randf()
		if explosion_chance < 0.33:
			new_explosion.spawn_audio = EXPLOSION_1_SFX
		elif explosion_chance < 0.66:
			new_explosion.spawn_audio = EXPLOSION_2_SFX
		else:
			new_explosion.spawn_audio = EXPLOSION_3_SFX
	
	bomb_sprite.self_modulate = Color(1, 1, 1, 0)
	bomb_shadow.self_modulate = Color(1, 1, 1, 0)
	airbrone_particles.emitting = false
	
	await get_tree().create_timer(0.8, false).timeout
	
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	bomb_sprite.rotation += deg_to_rad(delta * 275 * rand_flip)
