############################## Secondary Base ##############################
extends CharacterBody2D
class_name BaseSecondary

@export var default_power : float = 1.0
@export var power_mult : float = 1.0
var power : float = 0.0

#---------------------------------------------------------------------------------------------------------------------------
func _apply_mult():
	power = default_power * PlayerUpgradeStats.power_mult
