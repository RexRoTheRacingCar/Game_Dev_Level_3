############################## Health Component ##############################
extends Node2D
class_name HealthComponent


#Signals
signal zero_health

#Variables
@export var health_bar : ProgressBar
var health : float : set = _set_health


#---------------------------------------------------------------------------------------------------------------------------
func ready():
	health_bar.max_value = health
	health_bar.value = health


#---------------------------------------------------------------------------------------------------------------------------
#Health setter function
func _set_health(new_value : float) -> void:
	health = new_value
	health_bar.value = health
	
	if health <= 0:
		zero_health.emit()
