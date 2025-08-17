############################## PAUSE MENU ##############################
extends Resource
class_name Item

@export var item_name : String
@export var rarity : String
#Common ||| Rare ||| Epic ||| Legendary
@export var item_type : PackedScene

@export var item_cost : int = 10
@export var texture : Texture2D
@export var upgrade_type : String

@export var update_save_variable : String
