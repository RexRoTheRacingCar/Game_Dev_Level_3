############################## Secondary Controller ##############################
extends Node2D
class_name SecondaryController



@export var current_secondary : SecondaryAbility
var charge_progress : float = 0.0
var is_charging : bool = false

@export var progress_bar : ProgressBar
@onready var cooldown_timer = $CooldownTimer
var cooldown_active : bool = false


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	charge_progress = 0.0
	is_charging = false
	cooldown_active = false
	
	progress_bar.visible = false
	progress_bar.max_value = current_secondary.charge_time
	progress_bar.value = charge_progress


#---------------------------------------------------------------------------------------------------------------------------
func secondary_controls(delta : float):
	#Secondary charge up
	if Input.is_action_pressed("secondary_attack") and cooldown_active == false:
		charge_progress += delta
		charge_progress = clamp(charge_progress, 0.0, current_secondary.charge_time)
		progress_bar.value = charge_progress
		if progress_bar.visible == false:
			progress_bar.visible = true
		
		is_charging = true
	
	#Secondary button released. If cooldown progress = charge_time, spawn secondary ability
	if Input.is_action_just_released("secondary_attack"):
		if charge_progress >= current_secondary.charge_time - current_secondary.charge_time / 12:
			var new_secondary = current_secondary.spawn_scene(current_secondary.secondary_attack, get_tree().root.get_node("/root/Game/"))
			new_secondary.global_position = get_global_mouse_position()
			
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
