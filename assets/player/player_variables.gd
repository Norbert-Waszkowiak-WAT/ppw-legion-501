extends Node

var abilities = {
	# Movement
	"exoskeleton": false,
	"exoskeleton_2": false,
	"double_jump": false,
	"dash": false,
	"air_dash": false,
	"dash_charge": false,
	
	# Melee
	"force_push": false,
	"enhanced_plasma": false,
	"low_resistance_blade": false,
	"block": false,
	"deflect": false,
	
	# Ranged
	"large_mag":false,
	"high_speed_low_drag": false,
	"heavy_hitter": false,
	"hollow_points": false,
	"stopping_power": false,
	"large_caliber": false,
	"hollow_points_2": false,
	"stopping_power_2": false,
	"tuned_trigger": false,
	
	# Magic
	"bullet_time": false,
	"quake": false,
	"lazer": false,
	"bullet_time_2": false,
	"quake_2": false,
	"lazer_2": false,
	"bullet_time_3": false,
	"quake_3": false,
	"lazer_3": false
	
}

var double_jumped : bool = false

var dash_charges : int
var MAX_DASH_CHARGES : int = 1

var bullet_time_duration : float = 3.5

var quake_range : float = 80
var quake_strength : float = 85
var quake_damage : float = 20

var ammo : float
var MAX_AMMO : int = 50


var skill_points : float

var health : float
var MAX_HEALTH: float = 100.0

var experience : float
var exp_lvl : int
var MAX_EXP : float = 200

var loaded_save : String


func save_game(file_index : String):
	var level = get_parent().get_node("Level")
	var next_level
	
	var file = FileAccess.open("user://save_slot_" + file_index + ".save", FileAccess.WRITE)
	if level:
		next_level = level.next_level
	file.store_var(abilities)
	file.store_var(exp_lvl)
	file.store_var(MAX_EXP)
	file.store_var(experience)
	file.store_var(skill_points)
	file.store_var(next_level)
		
	file.close()


func load_game(file_index : String):
	var next_level
	if FileAccess.file_exists("user://save_slot_" + file_index + ".save"):
		var file = FileAccess.open("user://save_slot_" + file_index + ".save", FileAccess.READ)

		abilities.merge(file.get_var(), true)
		exp_lvl = file.get_var()
		MAX_EXP = file.get_var()
		experience = file.get_var()
		skill_points = file.get_var()
		next_level = file.get_var()
		
		file.close()
		loaded_save = file_index
	if next_level:
		get_tree().change_scene_to_file(next_level)
	else:
		get_tree().reload_current_scene()


func reset_player():
	abilities = {
	# Movement
	"exoskeleton": false,
	"exoskeleton_2": false,
	"double_jump": false,
	"dash": false,
	"air_dash": false,
	"dash_charge": false,
	
	# Melee
	"force_push": false,
	"enhanced_plasma": false,
	"low_resistance_blade": false,
	"block": false,
	"deflect": false,
	
	# Ranged
	"large_mag":false,
	"high_speed_low_drag": false,
	"heavy_hitter": false,
	"hollow_points": false,
	"stopping_power": false,
	"large_caliber": false,
	"hollow_points_2": false,
	"stopping_power_2": false,
	"tuned_trigger": false,
	
	# Magic
	"bullet_time": false,
	"quake": false,
	"lazer": false,
	"bullet_time_2": false,
	"quake_2": false,
	"lazer_2": false,
	"bullet_time_3": false,
	"quake_3": false,
	"lazer_3": false
	
	}
	exp_lvl = 0
	MAX_EXP = 200.0
	experience = 0
	skill_points = 0
	MAX_HEALTH = 100.0
	health = MAX_HEALTH
