extends Control


func _ready():
	print("asfasgd")

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")
	

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://assets/hud/hud.tscn")


func _on_exit_pressed():
	get_tree().quit()
