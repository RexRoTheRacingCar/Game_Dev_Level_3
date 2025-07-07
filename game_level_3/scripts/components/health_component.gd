############################## Health Component ##############################
extends Node2D
class_name HealthComponent


#Signals
signal zero_health

#Variables
@export var health_bar : ProgressBar 
@export var max_health : int = 100 : set = _set_max_health
var health : int : set = _set_health
var death_emitted : bool


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	health = max_health
	death_emitted = false
	
	_set_health(max_health)
	_set_max_health(max_health)
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		health_bar.visible = GlobalSettings.show_health_bars


#---------------------------------------------------------------------------------------------------------------------------
#Health setter function
func _set_health(new_value : int) -> void:
	health = new_value
	
	#If health is above max_health
	if health > max_health:
		health = max_health
	
	#If there is a health barse
	if health_bar:
		health_bar.value = health
		health_bar.visible = GlobalSettings.show_health_bars
	
	#If health is equal to or below 0
	if health <= 0 and death_emitted == false:
		health = 0
		zero_health.emit()
		death_emitted = true


#---------------------------------------------------------------------------------------------------------------------------
#Max Health setter function
func _set_max_health(new_value : int) -> void:
	max_health = new_value
	
	#If there is a health bar
	if health_bar:
		@warning_ignore("integer_division")
		health_bar.size.x = 50 + (max_health / 2)
		health_bar.position.x = -health_bar.size.x / 2
