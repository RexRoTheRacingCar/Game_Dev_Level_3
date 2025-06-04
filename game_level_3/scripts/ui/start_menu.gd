############################## Start Menu ##############################
extends Control

var all_buttons : Array = []
@onready var v_box_options: VBoxContainer = $PanelContainer/MarginContainer/MainVBox/VBoxOptions

var scene_array : Array = ["res://scenes/main/game.tscn", ]

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.current_main_scene = "Start Menu"
	
	#Loop connects all buttons and assigns button id bind
	all_buttons = v_box_options.get_children()
	for button in range(0, all_buttons.size()):
		all_buttons[button].pressed.connect(_button_pressed.bind(button))


#---------------------------------------------------------------------------------------------------------------------------
func _button_pressed(btn_id : int):
	match btn_id:
		0: #Start Game
			var _new_game = get_tree().change_scene_to_file(scene_array[btn_id])
		
		1: #Settings
			pass
			
		2: #Controls
			pass
			
		3: #Quit Game
			get_tree().quit()
