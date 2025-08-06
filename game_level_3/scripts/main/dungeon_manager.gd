############################## Dungeon Manager ##############################
extends Node2D

@export_group("Nodes")
@export var GAME_MANAGER : Node2D
@export var ROOM_MANAGER : Node2D
@export var PLAYER : Player

var room_generating : bool = false
var transitioning : bool = false

const PORTAL_ADVANCED = preload("res://scenes/misc/portal_advanced.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	Global.wave_counter = 0
	Global.enemy_count = 0 
	Global.enemy_wave = false
	Global.player = PLAYER
	
	Global.current_main_scene = "Game"
	Global.player_dead = false
	Global.player_coins = 0
	Global.rooms_cleared = 0
	Global.gems = 0
	PlayerUpgradeStats.power_mult = 1.0
	
	Global.connect("portal_entered", _new_room_transition)
	Global.connect("reset_to_menu", _reset_to_main_menu)
	
	room_generating = true
	transitioning = false
	
	_reset_room()


#---------------------------------------------------------------------------------------------------------------------------
#Generate a new room
func _reset_room():
	ROOM_MANAGER.generate_room()
	Global.rooms_cleared += 1
	Global.gems += 1
	Global.emit_signal("room_changed")
	
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


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	Global.wave_time += delta #Wave timer
	
	if room_generating == false:
		modulate = lerp(modulate, Color(1, 1, 1), 0.25)
	else:
		modulate = lerp(modulate, Color(0, 0, 0), 0.25)
	
	#WAVE GENERATION CONDITIONS
	if Global.enemy_count == 0 and GAME_MANAGER.is_generating == false:
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
	var portal_array : Array = ROOM_MANAGER.current_room.portal_spawn_array
	for positions in portal_array.size():
		var new_portal = PORTAL_ADVANCED.instantiate()
		new_portal.global_position = portal_array[positions].global_position
		get_tree().root.get_node("/root/Game/").add_child(new_portal)


#---------------------------------------------------------------------------------------------------------------------------
func _new_room_transition():
	Global.enemy_wave = true
	room_generating = true
	
	await get_tree().create_timer(1.0, true).timeout 
	
	_reset_room()
	transitioning = false


#---------------------------------------------------------------------------------------------------------------------------
func _reset_to_main_menu():
	Global.current_main_scene = "Start Menu"
	var _main_menu = get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
