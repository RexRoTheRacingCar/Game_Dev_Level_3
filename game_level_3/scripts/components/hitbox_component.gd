############################## Hitbox Component ##############################
extends Area2D
class_name HitboxComponent


#Signals
signal hitbox_entered(atk_dmg : float, atk_kckbck : float, atk_stun : float)

#Timer variables
@export var hit_timer : Timer
@export var hit_delay : float = 1.0
var is_hit : bool = false

#Hitbox variables
@export var hitbox_shape : Node2D
var detect_arr : Array = []


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	detect_arr = []
	is_hit = false


#---------------------------------------------------------------------------------------------------------------------------
#When body enters hit area
func _on_body_entered(body: HurtboxComponent):
	detect_arr.append(body)
	
	if is_hit == false:
		_hit_signal()
		is_hit = true
		
		hit_timer.start(hit_delay)


#When body exits hit area
func _on_body_exited(body: HurtboxComponent):
	detect_arr.erase(body)


#---------------------------------------------------------------------------------------------------------------------------
#When hit timer runs out
func _on_hit_timer_timeout():
	is_hit = false
	
	if detect_arr.is_empty() == false:
		_hit_signal()


#---------------------------------------------------------------------------------------------------------------------------
#Hit signal function call
func _hit_signal():
	hitbox_entered.emit(detect_arr[0])
