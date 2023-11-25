extends Control


func _ready():
	$player.spawn($player_spawnpoint.position)
	$player.set_process_input(false)
	$player/Camera2D.enabled = false
	$player/HUD.visible = false

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")
	

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("")


func _on_exit_pressed():
	get_tree().quit()
