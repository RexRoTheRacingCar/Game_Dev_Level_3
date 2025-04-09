############################## PAUSE MENU ##############################
extends CanvasLayer


#Pause Menu
var is_paused := false : 
	set(new_value): #Update pause variable
		is_paused = new_value
		get_tree().paused = is_paused
		visible = is_paused


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("esc"):
		is_paused = !is_paused


#---------------------------------------------------------------------------------------------------------------------------
func _on_button_pressed() -> void:
	get_tree().quit() #Quit game 
