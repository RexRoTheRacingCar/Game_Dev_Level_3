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

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	panel_container.visible = true
	is_paused = false
	input_settings_open = false


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
func _on_keybindings_button_pressed():
	input_settings_open = true
	input_settings.visible = true
	panel_container.visible = false


#---------------------------------------------------------------------------------------------------------------------------
func _on_quit_button_pressed() -> void:
	get_tree().quit() #Quit game 
