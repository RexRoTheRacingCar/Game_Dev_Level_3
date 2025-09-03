############################## Advanced Portal ##############################
extends PortalBase

@export var is_lobby_portal : bool = false
@export var item_rewards : RandomItemResource = preload("res://misc/resources/shop_item_pool.tres")
@onready var reward_sprite = $Sprites/Reward
var reward_item : Item

@onready var item_label = %Item
@onready var sprite_folder = $Sprites

const REWARD_SCENE = preload("res://scenes/entity/stat_upgrade.tscn")
var non_upgrade_reward_chance : float = 0.35
var non_upgrade_reward_dict : Dictionary = {
	0 : "Coins",
	1 : "Healing",
	2 : "Rerolls",
	3 : "Gems",
}
var rand_select
var rand_reward_chance : float

@export var x_offset : float = 0
var boss_chance : float = 0
var is_boss_portal : bool = false

const PORTAL_ENTERED_SFX = preload("res://assets/audio/diegetic_sfx/portal_entered.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	var rand_value : float = randf()
	var x : float = float(Global.rooms_cleared) - x_offset
	boss_chance = ((x - 0) ** 3) / 1
	boss_chance = clamp(boss_chance, 0.0, 0.8)
	
	_portal_prep()
	
	if is_lobby_portal == false:
		if rand_value < boss_chance:
			sprite_folder.modulate = Color(1, 0, 0)
			reward_sprite.texture.region = Rect2(600, 200, 100, 100)
			item_label.text = "   BOSS FIGHT   "
			
			is_boss_portal = true 
		else:
			rand_reward_chance = randf()
			if rand_reward_chance >= non_upgrade_reward_chance:
				get_random_item()
				
			else:
				get_random_non_upgrade()
	else:
		reward_sprite.texture.region = Rect2(100, 300, 100, 100)
		item_label.text = "   BEGIN   "


#---------------------------------------------------------------------------------------------------------------------------
#Choose a random item from an item pool with a rarity system
func get_random_item():
	var rarity = Global.get_rarity(item_rewards.rarities) #Choose a rarity
	var temp_array : Array = item_rewards.item_pool
	var items_array : Array = []
	
	#Add chosen rarity items to list
	for item in temp_array:
		if item.rarity == rarity:
			items_array.append(item)
	
	#Choose a random item from the list
	var selection = randi() % items_array.size()
	reward_item = items_array[selection]
	
	reward_sprite.texture = reward_item.texture.duplicate()
	item_label.text = reward_item.item_name


#---------------------------------------------------------------------------------------------------------------------------
func get_random_non_upgrade():
	rand_select = randi_range(0, non_upgrade_reward_dict.size() - 1)
	
	#Select a random non_item
	match non_upgrade_reward_dict[rand_select]:
		"Coins" : 
			reward_sprite.texture.region = Rect2(0, 200, 100, 100)
			item_label.text = "Coins"
		"Healing" : 
			reward_sprite.texture.region = Rect2(300, 300, 100, 100)
			item_label.text = "Healing"
		"Rerolls" : 
			reward_sprite.texture.region = Rect2(400, 200, 100, 100)
			item_label.text = "Rerolls"
		"Gems" :
			reward_sprite.texture.region = Rect2(500, 200, 100, 100)
			item_label.text = "Gems"


#---------------------------------------------------------------------------------------------------------------------------
func _on_player_detect_body_entered(body : Player):
	if has_detected_player == false:
		AudioManager.play_sound(PORTAL_ENTERED_SFX, "SFX", true)
		if is_boss_portal == true: #If Portal leads to Boss Room
			has_detected_player = true
			target_alpha = 0.0
			Global.emit_signal("boss_portal_entered")
			
		else: #If it is a normal portal
			_spawn_room_reward()
			super._on_player_detect_body_entered(body)


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_room_reward():
	if is_lobby_portal == false:
		#If upgrade
		if rand_reward_chance >= non_upgrade_reward_chance and reward_item:
			var new_reward = REWARD_SCENE.instantiate()
			new_reward.global_position = Global.player_position
			new_reward.upgrade = reward_item
			new_reward.track_player = true
			get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_reward)
		
		#If non_upgrade
		else:
			match non_upgrade_reward_dict[rand_select]:
				"Coins" : 
					Global.player_coins += 50
				"Healing" : 
					Global.player.P_HEALTH_COMPONENT.health += 50
				"Rerolls" : 
					Global.player_rerolls += 2
				"Gems" :
					Global.gems += 5


#---------------------------------------------------------------------------------------------------------------------------
func _other_portal_entered():
	if has_detected_player == false:
		reward_sprite.texture.region = Rect2(300, 200, 100, 100)
	
	super._other_portal_entered()
