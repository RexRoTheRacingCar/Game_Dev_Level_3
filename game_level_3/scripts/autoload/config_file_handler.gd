############################## Config File Handler ##############################
extends Node


var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		#Keybinds
		config.set_value("keybinding", "left", "A")
		config.set_value("keybinding", "right", "D")
		config.set_value("keybinding", "up", "W")
		config.set_value("keybinding", "down", "S")
		config.set_value("keybinding", "dash", "Space")
		config.set_value("keybinding", "primary_attack", "mouse_1")
		config.set_value("keybinding", "secondary_attack", "mouse_2")
		config.set_value("keybinding", "reload", "mouse_3")
		config.set_value("keybinding", "esc", "Escape")
		config.set_value("keybinding", "open_debug", "Ctrl")
		
		#Video / Window
		config.set_value("video", "screen_resolution", 0)
		config.set_value("video", "fullscreen", true)
		
		#Graphics / Gameplay
		config.set_value("graphics", "limited_particles", false)
		config.set_value("graphics", "show_health_bars", true)
		config.set_value("graphics", "screenshake_multiplier", 1.0)
		
		#Audio
		config.set_value("audio", "master_volume", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


#Save / Load Window & Video Settings
#---------------------------------------------------------------------------------------------------------------------------
func save_video_setting(key : String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)


#---------------------------------------------------------------------------------------------------------------------------
func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings


#Save / Load Graphics
#---------------------------------------------------------------------------------------------------------------------------
func save_graphics_setting(key : String, value):
	config.set_value("graphics", key, value)
	config.save(SETTINGS_FILE_PATH)


#---------------------------------------------------------------------------------------------------------------------------
func load_graphics_settings():
	var graphics_setting = {}
	for key in config.get_section_keys("graphics"):
		graphics_setting[key] = config.get_value("graphics", key)
	return graphics_setting


#Save / Load Audio
#---------------------------------------------------------------------------------------------------------------------------
func save_audio_settings(key : String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)


#---------------------------------------------------------------------------------------------------------------------------
func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings


#Save / Load Keybinds
#---------------------------------------------------------------------------------------------------------------------------
func save_keybinding(action : StringName, event : InputEvent):
	var event_str 
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)


#---------------------------------------------------------------------------------------------------------------------------
func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
	return keybindings
