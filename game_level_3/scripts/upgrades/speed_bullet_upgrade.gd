############################## Speed Bullet Base ##############################
extends BaseUpgrade
class_name SpeedBulletUpgrade

@export var speed_increase : int = 50

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	bullet.speed += speed_increase
