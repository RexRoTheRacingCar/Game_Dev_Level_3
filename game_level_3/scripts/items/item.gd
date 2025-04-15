############################## PAUSE MENU ##############################
extends Resource
class_name Item

@export var rarity : String
#Common ||| Rare ||| Epic ||| Legendary
@export var item_type : PackedScene

@export var item_cost : int = 10
@export var texture : Texture2D
@export var upgrade_type : String
