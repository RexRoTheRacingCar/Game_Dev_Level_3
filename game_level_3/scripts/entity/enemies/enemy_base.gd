############################## Enemy Base ##############################
extends Resource
class_name EnemyBase


@export_group("Necessary")
@export var health : int = 20
@export var spritesheet : Texture2D
@export var texture_size : Vector2
@export var state_array : Array
@export var hitbox_shape : Shape2D
