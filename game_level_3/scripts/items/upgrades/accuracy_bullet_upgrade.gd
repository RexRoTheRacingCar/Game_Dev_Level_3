############################## Bullet Accuracy Upgrade ##############################
extends BaseUpgrade
class_name AccuracyBulletUpgrade

@export var accuracy_increase : float = 1.6

#---------------------------------------------------------------------------------------------------------------------------
#Apply bullet upgrade to bullet
func apply_upgrade(bullet: Bullet):
	bullet.accuracy /= accuracy_increase
