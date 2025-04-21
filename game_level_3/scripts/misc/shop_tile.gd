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
@onready var particle_1 = $SpriteFolder/GPUParticles2D

#Scenes & Resources
@export var item_pool : RandomItemResource
var dust_particle : PackedScene = preload("res://scenes/entity/particles/dust_splash1.tscn")


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	particle_1.self_modulate = Color(1, 1, 1, 1)
	
	get_random_item()
	
	reward_sprite.visible = true
	shop_tile.visible = true 
	price_ui.visible = true
	lock_sprite.visible = false
	
	collision.disabled = false
	
	#Update all displays
	#Rewards
	reward_sprite.texture = display_item.texture
	reward_sprite.self_modulate = Color(0.55, 0.55, 0.55, 0.92)
	#Pricing
	price = display_item.item_cost
	price_label.text = str(price)
	#Display Tile
	shop_tile.texture.region = Rect2(480, 180, 120, 120)

#---------------------------------------------------------------------------------------------------------------------------
#When player enters shop tile radius 
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		if Global.player_coins >= price: #If player can afford upgrade
			Global.player_coins -= price
			
			for _shake in range(0, 16):
				shop_tile.position.x = randf_range(3.0, -3.0)
				await get_tree().create_timer(0.02, false).timeout
			
			spawn_upgrade()
			Global.spawn_particle(global_position, self, dust_particle)
			
			queue_free()
		else: #If player can't afford upgrade
			print("Get More Money")


#---------------------------------------------------------------------------------------------------------------------------
#Spawn the reward item after interaction
func spawn_upgrade():
	var new_scene = display_item.item_type.instantiate()
	get_parent().call_deferred("add_child", new_scene)
	new_scene.global_position = Vector2(global_position.x, global_position.y - 30)
	new_scene.upgrade = display_item


#---------------------------------------------------------------------------------------------------------------------------
#Choose a random item from an item pool with a rarity system
func get_random_item():
	var rarity = Global.get_rarity(item_pool.rarities) #Choose a rarity
	var temp_array : Array = item_pool.item_pool
	var items_array : Array = []
	
	#Add chosen rarity items to list
	for n in temp_array:
		if n.rarity == rarity:
			items_array.append(n)
	
	#Choose a random item from the list
	print(rarity)
	var selection = randi() % items_array.size()
	display_item = items_array[selection]
	
	#Misc for paritcle effects
	if rarity == "Rare":
		particle_1.self_modulate = Color(0.34, 1, 1, 1)
	elif rarity == "Epic":
		particle_1.self_modulate = Color(0.836, 0.351, 0.9, 1)
	elif rarity == "Legendary":
		particle_1.self_modulate = Color(0.95, 0.697, 0, 1)
