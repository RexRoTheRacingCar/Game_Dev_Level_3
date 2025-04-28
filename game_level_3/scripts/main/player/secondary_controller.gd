############################## Secondary Controller ##############################
extends Node2D
class_name SecondaryController


@export var current_secondary : SecondaryAbility
var charge_progress : float = 0.0
var is_charging : bool = false
var is_outline : bool = false
var outline_sprite : Sprite2D
var new_outline_sprite

@export var progress_bar : ProgressBar
@onready var cooldown_timer = $CooldownTimer
var cooldown_active : bool = false


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	#Outline sprite
	if current_secondary.secondary_outline:
		outline_sprite = Sprite2D.new()
		new_outline_sprite = get_tree().root.get_node("/root/Game/").call_deferred("add_child", outline_sprite)
	
	charge_progress = 0.0
	is_charging = false
	cooldown_active = false
	
	progress_bar.visible = false
	progress_bar.max_value = current_secondary.charge_time
	progress_bar.value = charge_progress
	
	await get_tree().create_timer(0.1, false).timeout 
	
	if current_secondary.secondary_outline:
		new_outline_sprite.z_index = 12
		new_outline_sprite.visible = false
		new_outline_sprite.texture = current_secondary.secondary_outline


#---------------------------------------------------------------------------------------------------------------------------
func secondary_controls(delta : float):
	is_charging = false
	
	#Secondary charge up
	if Input.is_action_pressed("secondary_attack") and cooldown_active == false:
		if current_secondary.secondary_outline:
			new_outline_sprite.visible = true
			new_outline_sprite.global_position = _get_position_type()
		
		#Update secondary charge and progress bar
		charge_progress += delta
		charge_progress = clamp(charge_progress, 0.0, current_secondary.charge_time)
		progress_bar.value = charge_progress
		if progress_bar.visible == false:
			progress_bar.visible = true
		
		is_charging = true
	else:
		if current_secondary.secondary_outline:
			new_outline_sprite.visible = false
		
		charge_progress -= 0.5 * delta
		charge_progress = clamp(charge_progress, 0.0, current_secondary.charge_time)
	
	#Secondary button released. If cooldown progress = charge_time, spawn secondary ability
	if Input.is_action_just_released("secondary_attack"):
		if charge_progress >= current_secondary.charge_time - current_secondary.charge_time / 12:
			var new_secondary = current_secondary.spawn_scene(current_secondary.secondary_attack, get_tree().root.get_node("/root/Game/"))
			new_secondary.global_position = _get_position_type()
			
			#Start cooldown timer
			cooldown_timer.start(current_secondary.cooldown)
			cooldown_active = true
			
			#Cooldown progress tween
			var cooldown_tween = create_tween()
			cooldown_tween.tween_property(progress_bar, "value", 0.0, current_secondary.cooldown)
		
		elif cooldown_active == false:
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
