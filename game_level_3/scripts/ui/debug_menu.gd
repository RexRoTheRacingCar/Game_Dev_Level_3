############################## Debug Menu ##############################
extends Control

#Toggle Debug Menu
var is_enabled = false :
	set(new_value):
		is_enabled = new_value
		visible = new_value

@onready var FPS_LABEL = %FPSLabel
@onready var ENEMY_WAVE = %EnemyWave
@onready var ENEMY_COUNTER = %EnemyCounter
@onready var WAVE_TIMER = %WaveTimer
@onready var WAVE_COUNTER = %WaveCounter
@onready var MAX_WAVES = %MaxWaves
@onready var POWER_MULT = %PowerMult
@onready var rooms_cleared = %RoomsCleared

var fps : String


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	is_enabled = false


#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("open_debug"):
		is_enabled = !is_enabled 


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	if is_enabled == true:
		#Find FPS based on approx delta time
		fps = "%.2f" % (1.0 / delta)
		FPS_LABEL.text = "FPS : " + fps
		ENEMY_WAVE.text = str("Wave Enabled : ", Global.enemy_wave)
		ENEMY_COUNTER.text = str("Enemy Count : ", Global.enemy_count)
		WAVE_TIMER.text = str("Wave Time : ", "%.2f" % Global.wave_time)
		WAVE_COUNTER.text = str("Wave Count : ", Global.wave_counter)
		MAX_WAVES.text = str("Current Max Waves : ", Global.current_max_waves)
		POWER_MULT.text = str("Player PWR MULT : ", PlayerUpgradeStats.power_mult)
		rooms_cleared.text = str("Rooms Cleared : ", Global.rooms_cleared)
