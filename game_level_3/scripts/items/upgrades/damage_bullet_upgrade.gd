############################## Bullet Damage Upgrade ##############################
extends BaseUpgrade
class_name DamageBulletUpgrade

@export var damage_increase : int = 5

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	bullet.damage += damage_increase
