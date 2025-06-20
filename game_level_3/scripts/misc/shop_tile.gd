############################## Shop Tile ##############################
extends StaticBody2D


var display_item : Item
var price : int

#Nodes
@export var reward_sprite : Sprite2D
@export var shop_tile : Sprite2D

@onready var coins = %Coins
@onready var item = %Item
@onready var swap_timer = %SwapTimer

@onready var collision = $CollisionPolygon2D
@onready var price_ui = $PriceUI
@onready var particle_1 = $SpriteFolder/GPUParticles2D
@onready var animation_player = $AnimationPlayer

#Scenes & Resources
@export var item_pool : RandomItemResource
const DUST_PARTICLE : PackedScene = preload("res://scenes/entity/particles/dust_splash1.tscn")
const LOCKED_INDICATOR = preload("res://scenes/misc/locked_indicator.tscn")

var text_state : String = "name"
var swap_time : float = 4.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	particle_1.self_modulate = Color(1, 1, 1, 1)
	
	get_random_item()
	
	reward_sprite.visible = true
	shop_tile.visible = true 
	collision.disabled = false
	
	_update_display()
	
	swap_timer.start(swap_time * 2.0)
	swap_timer.connect("timeout", _timer_swapped)


#---------------------------------------------------------------------------------------------------------------------------
#Update all displays
func _update_display():
	text_state = "name"
	animation_player.play("price_to_name")
	#Rewards
	reward_sprite.texture = display_item.texture
	reward_sprite.self_modulate = Color(0.55, 0.55, 0.55, 0.92)
	#Pricing
	price = display_item.item_cost
	coins.text = str(price)
	item.text = display_item.item_name
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
			Global.spawn_particle(global_position, self, DUST_PARTICLE)
			
			queue_free()
		
		else: #If player can't afford upgrade
			var new_locked_scene = LOCKED_INDICATOR.instantiate()
			get_parent().call_deferred("add_child", new_locked_scene)
			new_locked_scene.global_position = Vector2(global_position.x, global_position.y - 35)


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


#---------------------------------------------------------------------------------------------------------------------------
func _timer_swapped():
	if text_state == "price":
		animation_player.play("price_to_name")
		text_state = "name"
	else:
		animation_player.play("name_to_price")
		text_state = "price"
	
	swap_timer.start(swap_time)
