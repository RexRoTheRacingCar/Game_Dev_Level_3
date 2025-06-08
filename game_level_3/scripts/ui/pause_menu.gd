############################## PAUSE MENU ##############################
extends Control

@export var input_settings : Control
@onready var input_settings_open : bool = false

#Pause Menu
var is_paused := false : 
	set(new_value): #Update pause variable
		is_paused = new_value
		get_tree().paused = is_paused
		visible = is_paused

@onready var panel_container = $PanelContainer
@onready var v_box_options = $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer
var all_buttons : Array = []

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	panel_container.visible = true
	is_paused = false
	input_settings_open = false
	
		#Loop connects all buttons and assigns button id bind
	all_buttons = v_box_options.get_children()
	for button in range(0, all_buttons.size()):
		all_buttons[button].pressed.connect(_button_pressed.bind(button))


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("esc"):
		if input_settings_open == false:
			is_paused = !is_paused
		elif input_settings_open == true:
			input_settings_open = false
			input_settings.visible = false
			panel_container.visible = true


#---------------------------------------------------------------------------------------------------------------------------
func _button_pressed(btn_id : int):
	match btn_id:
		0: #Controls / Keybinds
			input_settings_open = true
			input_settings.visible = true
			panel_container.visible = false
		
		1: #Settings
			var _new_menu = get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
			
		2: #Quit Game
			get_tree().quit()
