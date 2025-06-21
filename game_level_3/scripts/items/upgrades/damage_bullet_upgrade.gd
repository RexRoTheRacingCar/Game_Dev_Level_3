############################## Bullet Damage Upgrade ##############################
extends BaseUpgrade
class_name DamageBulletUpgrade

@export var damage_increase : float = 2.0

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	@warning_ignore("integer_division")
	var dmg : int = ceil(bullet.default_damage / damage_increase)
	bullet.damage += clamp(dmg, 1, 999999)
