############################## Start Menu ##############################
extends Control

var all_buttons : Array = []
@onready var v_box_options: VBoxContainer = $PanelContainer/MarginContainer/MainVBox/VBoxOptions

var all_settings : Array = []
@onready var settings_options = $SettingsOptions

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.current_main_scene = "Start Menu"
	get_tree().paused = false
	
	connect_buttons()


#---------------------------------------------------------------------------------------------------------------------------
func connect_buttons():
	#Loop connects all buttons and assigns button id bind
	all_buttons = v_box_options.get_children()
	for button in range(0, all_buttons.size()):
		all_buttons[button].pressed.connect(_button_pressed.bind(button))
	
	all_settings = settings_options.get_children()


#---------------------------------------------------------------------------------------------------------------------------
func _button_pressed(btn_id : int):
	match btn_id:
		0: #Start Game
			var game : PackedScene = preload("res://scenes/main/game.tscn")
			get_tree().change_scene_to_packed(game)
		
		1: #Settings
			var gen_menu_id = all_settings.rfind(%GeneralSettings)
			all_settings[gen_menu_id].visible = !all_settings[gen_menu_id].visible
		
		2: #Controls
			var ctrl_menu_id = all_settings.rfind(%InputSettings)
			all_settings[ctrl_menu_id].visible = !all_settings[ctrl_menu_id].visible
		
		3: #How to Play
			var tutorial_menu_id = all_settings.rfind(%HowToPlay)
			all_settings[tutorial_menu_id].visible = !all_settings[tutorial_menu_id].visible
		
		4: #Quit Game
			get_tree().quit()


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("esc"):
		for menu in range(0, all_settings.size()):
			if all_settings[menu].visible == true:
				all_settings[menu].visible = false
