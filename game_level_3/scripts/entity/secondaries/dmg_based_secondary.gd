############################## Damage Based Secondary ##############################
extends BaseSecondary
class_name DamageBasedSecondary

@export var hurtbox : HurtboxComponent

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_apply_mult()
	
	if hurtbox:
		hurtbox.hurt_damage = round(power)
		hurtbox.hurt_knockback *= power_mult
		scale *= power_mult
