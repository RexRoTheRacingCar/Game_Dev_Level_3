############################## Secondary Controller ##############################
extends Node2D
class_name SecondaryController

@export var current_secondary : SecondaryAbility
var charge_progress : float = 0.0
var is_charging : bool = false
var is_outline : bool = false
var outline_sprite : Sprite2D
var can_spawn : bool
var new_outline_sprite

@export var progress_bar : ProgressBar
@onready var cooldown_timer = $CooldownTimer
@onready var sprite_2d: Sprite2D = $CanvasGroup/Sprite2D
var cooldown_active : bool = false

var progress : float = 0.0

#---------------------------------------------------------------------------------------------------------------------------
func _reset_secondary_controller():
	progress = 0.0
	charge_progress = 0.0
	is_charging = false
	cooldown_active = false
	can_spawn = false
	
	progress_bar.visible = false
	progress_bar.max_value = current_secondary.charge_time
	progress_bar.value = charge_progress
	
	sprite_2d.texture = current_secondary.secondary_outline
	sprite_2d.visible = true
	sprite_2d.self_modulate = Color(1, 1, 1, 0)
	sprite_2d.scale = Vector2(0, 0)


#---------------------------------------------------------------------------------------------------------------------------
func secondary_controls(delta : float):
	is_charging = false
	
	if Input.is_action_just_pressed("secondary_attack") and cooldown_active == false:
		sprite_2d.scale = Vector2(0, 0)
	
	#Secondary charge up
	if Input.is_action_pressed("secondary_attack") and cooldown_active == false:
		progress = charge_progress / current_secondary.charge_time
		
		sprite_2d.self_modulate = lerp(sprite_2d.self_modulate, Color(1, 1, 1, 0.6), Global.weighted_lerp(2, delta))
		sprite_2d.global_position = _get_position_type()
		sprite_2d.rotation_degrees += (125 * progress) * delta
		sprite_2d.scale = PlayerUpgradeStats.power_mult * progress * Vector2(current_secondary.max_scale, current_secondary.max_scale)
		
		#Update secondary charge and progress bar
		charge_progress += delta
		charge_progress = clamp(charge_progress, 0.0, current_secondary.charge_time)
		progress_bar.value = charge_progress
		if progress_bar.visible == false:
			progress_bar.visible = true
		
		is_charging = true
		
	else:
		if current_secondary.max_charge_req == true:
			if charge_progress >= current_secondary.charge_time - current_secondary.charge_time / 10:
				can_spawn = true
			else:
				charge_progress = 0
		
		modulate_lerp(delta)
		
		charge_progress -= 0.5 * delta
		charge_progress = clamp(charge_progress, 0.0, current_secondary.charge_time)
	
	#Secondary button released. If cooldown progress = charge_time, spawn secondary ability
	if Input.is_action_just_released("secondary_attack"):
		if (
			(charge_progress > 0.0 and current_secondary.max_charge_req == false) or 
			(current_secondary.max_charge_req == true and can_spawn == true)
			):
			can_spawn = false
			
			#Spawn secondary attack scene
			var new_secondary = current_secondary.spawn_scene(current_secondary.secondary_attack, get_tree().root.get_node("/root/Game/"))
			new_secondary.global_position = _get_position_type()
			
			#Adjust secondary attack if scale_based == true
			if current_secondary.scale_based == true:
				new_secondary.scale = (progress) * Vector2(current_secondary.max_scale, current_secondary.max_scale)
			
			if current_secondary.sound_on_use:
				AudioManager.play_2d_sound(current_secondary.sound_on_use, "SFX", new_secondary.global_position, true)
			
			#Cooldown 
			var cooldown_actual_time : float = current_secondary.cooldown
			if current_secondary.max_charge_req == false:
				cooldown_actual_time *= clamp(progress + 0.25, 0.0, 1.0)
			cooldown_timer.start(cooldown_actual_time)
			cooldown_active = true
			
			Camera.apply_camera_shake(current_secondary.shake_on_use)
			
			#Cooldown progress tween
			var cooldown_tween = create_tween()
			cooldown_tween.tween_property(progress_bar, "value", 0.0, cooldown_actual_time)
			
			if cooldown_active == false:
				progress_bar.visible = false
		
		elif current_secondary.max_charge_req == true and can_spawn == false and cooldown_active == false:
			progress_bar.visible = false
		
		charge_progress = 0
		is_charging = false


#---------------------------------------------------------------------------------------------------------------------------
func _on_cooldown_timer_timeout():
	cooldown_active = false
	progress_bar.visible = false


#---------------------------------------------------------------------------------------------------------------------------
#Return vector2 value based on spawn_location_type
func _get_position_type() -> Vector2:
	if current_secondary.spawn_location_type == 1:
		return get_global_mouse_position()
	elif current_secondary.spawn_location_type == 2:
		return Global.player_position
	
	return Vector2.ZERO


#---------------------------------------------------------------------------------------------------------------------------
func modulate_lerp(delta):
	sprite_2d.self_modulate = lerp(sprite_2d.self_modulate, Color(1, 1, 1, 0), Global.weighted_lerp(30, delta))
