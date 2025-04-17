############################## Knockback Bullet Upgrade ##############################
extends BaseUpgrade
class_name KnockbackBulletUpgrade

@export var knockback_increase : float = 4

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	bullet.knockback += bullet.default_knockback * knockback_increase
