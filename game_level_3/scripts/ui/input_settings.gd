############################## Input Settings ##############################
extends Control


@onready var input_button_scene : PackedScene = preload("res://scenes/ui/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_reamapping : bool = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"up" : "Move Up",
	"left" : "Move Left",
	"down" : "Move Down",
	"right" : "Move Right",
	"dash" : "Dash",
	"primary_attack" : "Primary Attack",
	"secondary_attack" : "Secondary Attack",
	"esc" : "Escape Menu",
	
}


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_create_action_list()


#---------------------------------------------------------------------------------------------------------------------------
func _create_action_list():
	InputMap.load_from_project_settings()
	#Clear current action list
	for item in action_list.get_children(): 
		item.queue_free()
	
	#Update action list
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		#Update button text
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		#Create the actual button
		action_list.add_child(button)
		#Connect to button "pressed" signal
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


#---------------------------------------------------------------------------------------------------------------------------
func _on_input_button_pressed(button, action):
	#When button pressed, setup remapping
	if !is_reamapping:
		is_reamapping = true
		action_to_remap = action
		remapping_button = button
		
		#Update button remapping text
		button.find_child("LabelInput").text = "Press Key to Bind..."


#---------------------------------------------------------------------------------------------------------------------------
func _input(event):
	#Update remapped inputs
	if is_reamapping:
		if (
			event is InputEventKey or 
			(event is InputEventMouseButton and event.pressed)
		):
			#Stop double click values being inputted
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			#Clear variable values
			is_reamapping = false
			action_to_remap = null
			remapping_button = null
			
			#Stop escape button closing menu
			accept_event()


#---------------------------------------------------------------------------------------------------------------------------
#Update remapped button text
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


#---------------------------------------------------------------------------------------------------------------------------
func _on_reset_button_pressed():
	_create_action_list()
