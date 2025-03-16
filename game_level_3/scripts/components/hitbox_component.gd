############################## Hitbox Component ##############################
extends Area2D
class_name HitboxComponent


#Signals
signal hitbox_entered(area: HurtboxComponent)

#Timer variables
@export var hit_timer : Timer
@export var hit_delay : float = 0.0
var is_hit : bool = false

#Hitbox variables
@export var single_hits : bool = false
var detect_array : Array = []
var secondary_array : Array = []


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	detect_array = []
	secondary_array = []
	is_hit = false


#---------------------------------------------------------------------------------------------------------------------------
#When hurtbox area enters hit area
func _on_area_entered(area: HurtboxComponent):
	if area != self:
		detect_array.append(area)
		
		if is_hit == false:
			_hit_signal()


#---------------------------------------------------------------------------------------------------------------------------
#When area exits hit area
func _on_area_exited(area: HurtboxComponent):
	if area != self:
		detect_array.erase(area)
		
		#Clear area from secondary array if it exists
		if secondary_array.find(area) != -1:
			secondary_array.erase(area)


#---------------------------------------------------------------------------------------------------------------------------
#When hit timer runs out
func _on_hit_timer_timeout():
	is_hit = false
	
	#if the detect array has a hurtbox
	if detect_array.is_empty() == false:
		if (single_hits == true and secondary_array.find(detect_array[0]) == -1) or single_hits == false:
			_hit_signal()


#---------------------------------------------------------------------------------------------------------------------------
#Hit signal function call
func _hit_signal():
	is_hit = true
	secondary_array.append(detect_array[0])
	hitbox_entered.emit(detect_array[0])
