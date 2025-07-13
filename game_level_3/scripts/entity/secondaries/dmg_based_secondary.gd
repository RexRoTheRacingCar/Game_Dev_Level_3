############################## Damage Based Secondary ##############################
extends BaseSecondary
class_name DamageBasedSecondary

@export var hurtbox : HurtboxComponent
@export var particle_folder : Node2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_apply_mult()
	
	if particle_nodes.is_empty() == false and particle_folder:
		particle_nodes = particle_folder.get_children()
	
	_particle_check()
	
	if hurtbox:
		hurtbox.hurt_damage = round(power)
		hurtbox.hurt_knockback *= power_mult
		scale *= power_mult
