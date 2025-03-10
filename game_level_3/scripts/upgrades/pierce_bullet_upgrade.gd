############################## Pierce Bullet Base ##############################
extends BaseBulletUpgrade
class_name PierceBulletUpgrade

@export var pierce_increase : int = 1

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	bullet.max_pierce += pierce_increase
