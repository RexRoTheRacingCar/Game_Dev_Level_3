############################## Bullet Damage Upgrade ##############################
extends BaseUpgrade
class_name DamageBulletUpgrade

@export var damage_increase : float = 2.0

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	var dmg : int = int(ceil(float(bullet.default_damage) / damage_increase))
	bullet.damage += clamp(dmg, 1, 999999)
