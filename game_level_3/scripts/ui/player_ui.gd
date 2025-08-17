############################## Player UI ##############################
extends CanvasLayer

#Label variables
@export var player_hp : Label
@export var player_health_bar : ProgressBar

@export var coins : Label
@export var gems : Label
@export var bullets : Label
@export var rerolls : Label
@export var game_time : Label

var can_count : bool = false


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.reset_to_lobby.connect(_disable_timer)
	follow_viewport_enabled = false


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	if can_count == true:
		Global.game_timer += delta
	else:
		Global.game_timer = 0.0
	
	#Updating UI text and other GUI
	player_hp.text = str("  ", Global.player_hp, "  I  ", Global.player_max_hp)
	
	player_health_bar.max_value = Global.player_max_hp
	player_health_bar.value = Global.player_hp
	
	coins.text = str(Global.player_coins, " ")
	gems.text = str(Global.gems, " ")
	bullets.text = str(Global.player_ammo, "  I  ", Global.player_max_ammo, " ")
	rerolls.text = str(Global.player_rerolls, " ")
	
	#Game Timer
	game_time.visible = GlobalSettings.show_stopwatch
	if GlobalSettings.show_stopwatch == true:
		var mils = fmod(Global.game_timer, 1) * 1000 
		var secs = fmod(Global.game_timer, 60)
		var mins = fmod(Global.game_timer, 60 * 60) / 60
		var time_passed = "%02d : %02d : %03d" % [mins, secs, mils]
		game_time.text = str(time_passed)


#---------------------------------------------------------------------------------------------------------------------------
func _disable_timer():
	can_count = false
