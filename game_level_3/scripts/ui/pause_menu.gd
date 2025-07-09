############################## PAUSE MENU ##############################
extends Control

@export var general_setttings : Control
@export var input_settings : Control

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
	input_settings.visible = false
	general_setttings.visible = false
	
	input_settings.connect("menu_closed", _force_menu_input)
	general_setttings.connect("menu_closed", _force_menu_input)
	
	#Loop connects all buttons and assigns button id bind
	all_buttons = v_box_options.get_children()
	for button in range(0, all_buttons.size()):
		all_buttons[button].pressed.connect(_button_pressed.bind(button))


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("esc"):
		if input_settings.visible == false and general_setttings.visible == false:
			is_paused = !is_paused
			panel_container.visible = is_paused
		elif input_settings.visible == true:
			input_settings.visible = false
			panel_container.visible = true
		elif general_setttings.visible == true:
			general_setttings.visible = false
			panel_container.visible = true


#---------------------------------------------------------------------------------------------------------------------------
func _button_pressed(btn_id : int):
	match btn_id:
		0: #Resume Game
			_force_menu_input()
		
		1: #Settings
			general_setttings.visible = true
			panel_container.visible = false
		
		2: #Controls / Keybinds
			input_settings.visible = true
			panel_container.visible = false
		
		3: #Main Menu
			var _new_menu = get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
			
		4: #Quit Game
			get_tree().quit()


#---------------------------------------------------------------------------------------------------------------------------
func _force_menu_input():
	var close_menu_event = InputEventAction.new()
	close_menu_event.action = "esc"
	close_menu_event.pressed = true
	Input.parse_input_event(close_menu_event)
