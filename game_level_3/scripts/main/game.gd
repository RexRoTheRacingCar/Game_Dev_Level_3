############################## Game (Delete or Change Later) ##############################
extends Node2D

const ENEMY := preload("res://scenes/entity/enemy/test_enemy.tscn")
const EXPLODE_ENEMY := preload("res://scenes/entity/enemy/exploding_enemy_1.tscn")
const BRUTE_ENEMY := preload("res://scenes/entity/enemy/brute_enemy.tscn")

const SPAWN_ANIMATION = preload("res://scenes/entity/spawn_animation.tscn")

@onready var room_generator : RoomGenerator = $RoomGenerator
@onready var game_manager = $GameManager
@onready var player = $Player

var changing_rooms : bool = false

#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		var spawn_anim = Global.spawn_particle(get_global_mouse_position(), $Player, SPAWN_ANIMATION)
		spawn_anim.enemy_scene = BRUTE_ENEMY


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	Global.player = player
	Global.current_main_scene = "Game"
	Global.player_dead = false
	Global.player_coins = 0
	PlayerUpgradeStats.power_mult = 1.0
	Global.wave_counter = 0
	
	changing_rooms = false
	
	_reset_room()


#---------------------------------------------------------------------------------------------------------------------------
func _reset_room():
	room_generator.generate_room()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player.global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	game_manager.max_waves = randi_range(1, 3)
	Global.enemy_wave = false
	modulate = Color(1, 1, 1)


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	if Global.player_dead == true:
		var _reload = get_tree().reload_current_scene()
		Global.player_dead = false
		
		get_tree().quit()
	
	if Global.enemy_count == 0 and changing_rooms == false and game_manager.is_generating == false:
		if Global.wave_counter >= game_manager.max_waves:
			changing_rooms = true
			Global.wave_counter = 0
			
			await get_tree().create_timer(2.0, false, false, false).timeout
			
			changing_rooms = false
			_reset_room()
		
		elif Global.wave_counter < game_manager.max_waves and Global.enemy_wave == false:
			game_manager._generate_wave()
			Global.enemy_wave = true
			Global.wave_time = 0
