extends Node

var abilities = {
	# Movement
	"double_jump": false,
	"dash": false,
	
	# Melee
	"deflect": false,
	
	# Ranged
	"high_speed_low_drag": false,
	"heavy_hitter": false
	
	# Magic
}

var double_jumped : bool = false

var skill_points : float

var health : float
var MAX_HEALTH: float = 100.0

var experience : float
var exp_lvl : int
var MAX_EXP : float = 100.0

var loaded_save : String


func save_game(file_index : String):
	var level = get_parent().get_node("Level")
	
	if level:
		var file = FileAccess.open("user://save_slot_" + file_index + ".save", FileAccess.WRITE)

		var next_level = level.next_level
		file.store_var(abilities)
		file.store_var(exp_lvl)
		file.store_var(MAX_EXP)
		file.store_var(experience)
		file.store_var(skill_points)
		file.store_var(next_level)
		
		file.close()


func load_game(file_index : String):
	var next_level : String
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
	get_tree().change_scene_to_file(next_level)


func reset_player():
	abilities = {
	# Movement
	"double_jump": false,
	"dash": false,
	
	# Melee
	"deflect": false
	
	# Ranged
	
	# Magic
	}
	exp_lvl = 0
	MAX_EXP = 100.0
	experience = 0
	skill_points = 0
	MAX_HEALTH = 100.0
	health = MAX_HEALTH
