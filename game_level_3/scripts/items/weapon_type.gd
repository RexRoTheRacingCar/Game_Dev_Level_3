############################## Weapon Types ##############################
extends Item
class_name WeaponType


@export_group("Default Values")
@export var default_bullet_amount : int = 1
@export var default_spread : float = 15.0
@export var default_burst_amount : int = 1
@export var default_firerate : float = 0.4
@export var default_reload_time : float = 0.4
@export var default_max_ammo : int = 18


@export_group("Other Values")
@export var default_bullet : PackedScene
@export var camera_shake : float = 4.0
@export var weapon_sprite : Texture2D
