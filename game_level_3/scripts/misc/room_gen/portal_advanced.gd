############################## Advanced Portal ##############################
extends PortalBase

@export var item_rewards : RandomItemResource = preload("res://misc/resources/shop_item_pool.tres")
@onready var reward_sprite = $Sprites/Reward
var reward_item : Item

@onready var item_label = %Item

const REWARD_SCENE = preload("res://scenes/entity/stat_upgrade.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_portal_prep()
	
	get_random_item()
	reward_sprite.texture = reward_item.texture.duplicate()
	item_label.text = reward_item.item_name


#---------------------------------------------------------------------------------------------------------------------------
#Choose a random item from an item pool with a rarity system
func get_random_item():
	var rarity = Global.get_rarity(item_rewards.rarities) #Choose a rarity
	var temp_array : Array = item_rewards.item_pool
	var items_array : Array = []
	
	#Add chosen rarity items to list
	for n in temp_array:
		if n.rarity == rarity:
			items_array.append(n)
	
	#Choose a random item from the list
	var selection = randi() % items_array.size()
	reward_item = items_array[selection]


#---------------------------------------------------------------------------------------------------------------------------
func _on_player_detect_body_entered(body : Player):
	if has_detected_player == false:
		super._on_player_detect_body_entered(body)
		_spawn_room_reward()


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_room_reward():
	var new_reward = REWARD_SCENE.instantiate()
	new_reward.global_position = Global.player_position
	new_reward.upgrade = reward_item
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_reward)
