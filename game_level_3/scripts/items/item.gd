############################## PAUSE MENU ##############################
extends Resource
class_name Item

@export var rarity : int
#0 = Common ||| 1 = Rare ||| 2 = Epic ||| 3 = Legendary
@export var item_type : PackedScene

@export var item_cost : int = 10
@export var texture : Texture2D
@export var upgrade_type : String
