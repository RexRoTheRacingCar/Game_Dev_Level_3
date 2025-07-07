############################## Input Settings ##############################
extends Control

#Window settings nodes
@onready var resolution_options = %ResolutionOptions
@onready var fullscreen_checkbox = %FullscreenCheckbox

#Graphics settings nodes
@onready var limited_particles_checkbox = %LimitedParticlesCheckbox
@onready var show_health_bars_checkbox = %ShowHealthBarsCheckbox
@onready var screen_shake_slider = %ScreenShakeSlider

#Audio settings nodes


#Misc
@onready var screen_shake_label = %ScreenShakeLabel

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	#Video Settings
	var video_settings = ConfigFileHandler.load_video_settings()
	resolution_options.selected = video_settings.screen_resolution
	fullscreen_checkbox.button_pressed = video_settings.fullscreen
	
	#Graphics Settings
	var graphics_settings = ConfigFileHandler.load_graphics_settings()
	limited_particles_checkbox.button_pressed = graphics_settings.limited_particles
	show_health_bars_checkbox.button_pressed = graphics_settings.show_health_bars
	screen_shake_slider.value = graphics_settings.screenshake_multiplier
	
	#ADD AUDIO SETTINGS LATER
	#Audio Settings
	var _audio_settings = ConfigFileHandler.load_audio_settings()
	
	
	_update_global_settings()
	_update_resolution()
	_update_fullscreen()


#Updates the global settings variables to match the save file
#---------------------------------------------------------------------------------------------------------------------------
func _update_global_settings():
	GlobalSettings.screen_resolution = resolution_options.selected
	GlobalSettings.fullscreen = fullscreen_checkbox.button_pressed
	GlobalSettings.limited_particles = limited_particles_checkbox.button_pressed
	GlobalSettings.show_health_bars = show_health_bars_checkbox.button_pressed
	GlobalSettings.screenshake_multiplier = screen_shake_slider.value
	
	screen_shake_label.text = "Screen Shake Multiplier (" + str(screen_shake_slider.value) + ")"


#---------------------------------------------------------------------------------------------------------------------------
func _on_close_menu_pressed():
	visible = false


#Updating the parts of the game based on loaded in variables
#---------------------------------------------------------------------------------------------------------------------------
func _update_resolution():
	match GlobalSettings.screen_resolution:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1536, 864))
		2:
			DisplayServer.window_set_size(Vector2i(1366, 768))
		3:
			DisplayServer.window_set_size(Vector2i(1280, 720))


#---------------------------------------------------------------------------------------------------------------------------
func _update_fullscreen():
	if GlobalSettings.fullscreen == true:
		var window := get_window()
		window.mode = Window.MODE_FULLSCREEN
	else:
		var window := get_window()
		window.mode = Window.MODE_WINDOWED
		window.borderless = false
		
		call_deferred("_update_resolution")


#All setting signals
#---------------------------------------------------------------------------------------------------------------------------
func _on_resolution_options_item_selected(index): #Screen Resolution
	ConfigFileHandler.save_video_setting("screen_resolution", index)
	GlobalSettings.screen_resolution = index
	call_deferred("_update_resolution")


func _on_fullscreen_checkbox_toggled(toggled_on): #Fullscreen
	ConfigFileHandler.save_video_setting("fullscreen", toggled_on)
	GlobalSettings.fullscreen = toggled_on
	call_deferred("_update_fullscreen")

func _on_limited_particles_checkbox_toggled(toggled_on): #Limited Particles
	ConfigFileHandler.save_graphics_setting("limited_particles", toggled_on)
	GlobalSettings.limited_particles = toggled_on

func _on_show_health_bars_checkbox_toggled(toggled_on): #Toggle Health Bars
	ConfigFileHandler.save_graphics_setting("show_health_bars", toggled_on)
	GlobalSettings.show_health_bars = toggled_on

func _on_screen_shake_slider_drag_ended(value_changed): #Screen Shake Multiplier
	if value_changed:
		ConfigFileHandler.save_graphics_setting("screenshake_multiplier", screen_shake_slider.value)
		GlobalSettings.screenshake_multiplier = screen_shake_slider.value
		screen_shake_label.text = "Screen Shake Multiplier (" + str(screen_shake_slider.value) + ")"
