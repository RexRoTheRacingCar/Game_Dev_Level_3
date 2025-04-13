############################## Shop Tile ##############################
extends StaticBody2D


var display_item : Item
var price : int

#Nodes
@export var reward_sprite : Sprite2D
@export var lock_sprite : Sprite2D
@export var shop_tile : Sprite2D
@export var price_label : Label
@onready var collision = $CollisionPolygon2D
@onready var price_ui = $PriceUI

#Scenes & Resources
@export var random_item : RandomItemResource
var dust_particle : PackedScene = preload("res://scenes/entity/particles/dust_splash1.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	get_random_item()
	
	reward_sprite.visible = true
	shop_tile.visible = true 
	price_ui.visible = true
	lock_sprite.visible = false
	
	collision.disabled = false
	
	#Update all displays
	#Rewards
	reward_sprite.texture = display_item.texture
	reward_sprite.self_modulate = Color(0.32, 0.32, 0.32, 0.75)
	#Pricing
	price = display_item.item_cost
	price_label.text = str(price)
	#Display Tile
	shop_tile.texture.region = Rect2(480, 180, 120, 120)

#---------------------------------------------------------------------------------------------------------------------------
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		if Global.player_coins >= price:
			Global.player_coins -= price
			
			for _shake in range(0, 16):
				shop_tile.position.x = randf_range(3.0, -3.0)
				await get_tree().create_timer(0.02, false).timeout
			
			spawn_upgrade()
			Global.spawn_particle(global_position, self, dust_particle)
			
			queue_free()
		else:
			print("Get More Money")


#---------------------------------------------------------------------------------------------------------------------------
func spawn_upgrade():
	var new_scene = display_item.item_type.instantiate()
	get_parent().call_deferred("add_child", new_scene)
	new_scene.global_position = Vector2(global_position.x, global_position.y - 30)
	new_scene.upgrade = display_item


#---------------------------------------------------------------------------------------------------------------------------
func get_random_item(): 
	var rarity = Global.get_rarity() #Choose a rarity
	var temp_array : Array = random_item.item_pool
	var items_array : Array = []
	
	#Add chosen rarity items to list
	for n in temp_array:
		if n.rarity == rarity:
			items_array.append(n)
	
	#Choose a random item from the list
	var selection = randi_range(0, temp_array.size() - 1)
	display_item = temp_array[selection]
