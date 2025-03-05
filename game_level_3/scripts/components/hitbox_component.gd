############################## Hitbox Component ##############################
extends Area2D
class_name HitboxComponent


#Signals
signal hitbox_entered(area: HurtboxComponent)

#Timer variables
@export var hit_timer : Timer
@export var hit_delay : float = 1.0
var is_hit : bool = false

#Hitbox variables
var detect_arr : Array = []


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	detect_arr = []
	is_hit = false


#---------------------------------------------------------------------------------------------------------------------------
#When hurtbox area enters hit area
func _on_area_entered(area: HurtboxComponent):
	if area != self:
		detect_arr.append(area)
		
		if is_hit == false:
			_hit_signal()


#When area exits hit area
func _on_area_exited(area: HurtboxComponent):
	if area != self:
		detect_arr.erase(area)


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
