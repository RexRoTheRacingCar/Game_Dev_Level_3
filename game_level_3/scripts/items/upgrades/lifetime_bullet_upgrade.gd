############################## Bullet Lifetime Upgrade ##############################
extends BaseUpgrade
class_name LifetimeBulletUpgrade

@export var lifetime_increase : float = 0.15

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	bullet.lifetime += bullet.default_lifetime / lifetime_increase
