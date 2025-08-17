############################## Save Load Script ##############################
extends Node

@export var save_data = LobbySaveData.new()
const SAVE_FILEPATH = "user://game_save.tres"


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_load()


#---------------------------------------------------------------------------------------------------------------------------
func _save():
	save_data.gems = Global.gems
	ResourceSaver.save(save_data, SAVE_FILEPATH)


#---------------------------------------------------------------------------------------------------------------------------
func _load():
	if FileAccess.file_exists(SAVE_FILEPATH):
		var data = ResourceLoader.load(SAVE_FILEPATH) as LobbySaveData
		Global.gems = data.gems
		save_data.gems = data.gems
		
		save_data.default_gun_unlocked = data.default_gun_unlocked
		save_data.bubble_gun_unlocked = data.bubble_gun_unlocked
		save_data.machine_gun_unlocked = data.machine_gun_unlocked
		
		save_data.knockback_sec_unlocked = data.knockback_sec_unlocked
		save_data.healing_sec_unlocked = data.healing_sec_unlocked
		save_data.turret_sec_unlocked = data.turret_sec_unlocked
