############################## Dungeon Manager ##############################
extends Node2D

@export_group("Nodes")
@export var GAME_MANAGER : Node2D
@export var ROOM_MANAGER : Node2D
@export var PLAYER : Player

var room_generating : bool = false

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.wave_counter = 0
	Global.enemy_count = 0 
	Global.enemy_wave = false
	Global.player = PLAYER
	
	room_generating = true
	
	_reset_room()


#---------------------------------------------------------------------------------------------------------------------------
#Generate a new room
func _reset_room():
	ROOM_MANAGER.generate_room()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	#Teleport player to random position on NavMesh
	PLAYER.global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	GAME_MANAGER.max_waves = randi_range(1, 3)
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
				Global.enemy_wave = true
				room_generating = true
				
				await get_tree().create_timer(1.0, true).timeout 
				
				_reset_room()
		
	
	#If enemies have been on screen for a while, spawn arrows to help guide the player
	if Global.enemy_count > 0 and Global.wave_time > (GAME_MANAGER.min_time_till_arrows + Global.enemy_count) and GAME_MANAGER.arrows_generated == false:
		GAME_MANAGER.arrows_generated = true
		GAME_MANAGER._create_arrows()
	
