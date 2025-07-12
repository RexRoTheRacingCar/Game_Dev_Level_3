############################## Damage Based Secondary ##############################
extends BaseSecondary
class_name DamageBasedSecondary

@export var hurtbox : HurtboxComponent
@onready var particle_folder = $ParticleFolder

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_apply_mult()
	
	particle_nodes = particle_folder.get_children()
	
	_particle_check()
	
	if hurtbox:
		hurtbox.hurt_damage = round(power)
		hurtbox.hurt_knockback *= power_mult
		scale *= power_mult
