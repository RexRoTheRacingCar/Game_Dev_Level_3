############################## Enemy Base ##############################
extends Resource
class_name EnemyBase

#Variables used in every enemy
@export_group("Necessary")
@export var spritesheet : Texture2D
@export var texture_size : Vector2
@export var line_of_sight_distance : float
