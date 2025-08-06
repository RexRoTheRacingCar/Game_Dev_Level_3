############################## Dungeon Manager ##############################
extends Node2D

@export_group("Nodes")
@export var GAME_MANAGER : Node2D
@export var ROOM_MANAGER : Node2D
@export var PLAYER : Player
@export var PLAYER_UI : CanvasLayer

var room_generating : bool = false
var transitioning : bool = false
var is_in_lobby : bool = false

const PORTAL_ADVANCED = preload("res://scenes/misc/portal_advanced.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	Global.player = PLAYER
	Global.current_main_scene = "Game"
	Global.gems = 0
	
	Global.portal_entered.connect(_new_room_transition)
	Global.reset_to_lobby.connect(_load_lobby)
	
	modulate = Color(0, 0, 0, 1)
	
	transitioning = false
	
	_load_lobby()


#---------------------------------------------------------------------------------------------------------------------------
func _load_lobby():
	is_in_lobby = true
	room_generating = true
	GAME_MANAGER.generate_waves = false
	GAME_MANAGER.loop_breaker = true
	PLAYER_UI.can_count = false
	
	await get_tree().create_timer(1.0, true).timeout
	
	#Load lobby room
	ROOM_MANAGER.load_lobby_room()
	PLAYER._reset_player()
	GAME_MANAGER.loop_breaker = false
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	PLAYER.global_position = Vector2.ZERO
	
	#Reset global variables
	Global.current_max_waves = 0
	Global.wave_counter = 0
	Global.enemy_wave = true
	
	Global.wave_counter = 0
	Global.enemy_count = 0 
	Global.enemy_wave = false
	Global.player_dead = false
	Global.player_coins = 0
	Global.rooms_cleared = -1
	PlayerUpgradeStats.power_mult = 1.0
	
	_spawn_set_position_portals()
	
	room_generating = false


#---------------------------------------------------------------------------------------------------------------------------
#Generate a new room
func _reset_room():
	GAME_MANAGER.generate_waves = true
	ROOM_MANAGER.generate_room()
	Global.rooms_cleared += 1
	Global.emit_signal("room_changed")
	
	if is_in_lobby == false:
		Global.gems += 1
	is_in_lobby = false
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	#Teleport player to random position on NavMesh
	GAME_MANAGER.max_waves = randi_range(1, 3)
	
	var posible_player_positions : Array = ROOM_MANAGER.current_room.portal_spawn_array
	PLAYER.global_position = posible_player_positions[
		randi_range(0, posible_player_positions.size() - 1)
		].global_position
	
	Global.current_max_waves = GAME_MANAGER.max_waves
	Global.wave_counter = 0
	Global.enemy_wave = false
	
	room_generating = false
	PLAYER_UI.can_count = true


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	Global.wave_time += delta #Wave timer
	
	if room_generating == false:
		modulate = lerp(modulate, Color(1, 1, 1), 0.25)
	else:
		modulate = lerp(modulate, Color(0, 0, 0), 0.25)
	
	#WAVE GENERATION CONDITIONS
	if Global.enemy_count == 0 and GAME_MANAGER.is_generating == false and GAME_MANAGER.generate_waves == true:
		#If no room is being generated
		if room_generating == false:
			Global.enemy_wave = false
		
		if Global.enemy_wave == false:
			#Start next wave
			if Global.wave_counter < GAME_MANAGER.max_waves:
				Global.enemy_wave = true
				GAME_MANAGER._generate_wave()
			
			#Go to next room before starting next wave
			elif Global.wave_counter >= GAME_MANAGER.max_waves:
				if transitioning == false:
					transitioning = true
					_spawn_set_position_portals()
					
					Global.emit_signal("room_cleared")
	
	#If enemies have been on screen for a while, spawn arrows to help guide the player
	if Global.enemy_count > 0 and Global.wave_time > (GAME_MANAGER.min_time_till_arrows + Global.enemy_count) and GAME_MANAGER.arrows_generated == false:
		GAME_MANAGER.arrows_generated = true
		GAME_MANAGER._create_arrows()


#Spawns advanced portals based on a preset array on portal positions
#---------------------------------------------------------------------------------------------------------------------------
func _spawn_set_position_portals():
	var portal_position_array : Array = ROOM_MANAGER.current_room.portal_spawn_array
	for positions in portal_position_array.size():
		var new_portal = PORTAL_ADVANCED.instantiate()
		new_portal.global_position = portal_position_array[positions].global_position
		new_portal.is_lobby_portal = is_in_lobby
		get_tree().root.get_node("/root/Game/").add_child(new_portal)
		


#---------------------------------------------------------------------------------------------------------------------------
func _new_room_transition():
	Global.enemy_wave = true
	room_generating = true
	
	await get_tree().create_timer(1.0, true).timeout
	
	_reset_room()
	transitioning = false
