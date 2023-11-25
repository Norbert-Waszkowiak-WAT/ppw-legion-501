extends Control


var start_game_delay : float = 2.5


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	startup_animation()


func _on_new_game_pressed():
	new_game_animation()
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("")


func _on_exit_pressed():
	get_tree().quit()


# Animacja gracza po włączeniu gry
func startup_animation():
	# Pojawienie się gracza, wyłączenie kontroli nad nim
	$player.spawn($player_spawnpoint.position)
	$player.set_process_input(false)
	
	# Wyłączenie kamery i interfejsu gracza
	$player/Camera2D.enabled = false
	$player/HUD.visible = false
	
	# Gracz wchodzi na ekran
	$player.walk("right", 1.2)


# Animacja gracza przed rozpoczęciem gry
func new_game_animation():
	# Gracz idzie w prawo
	$player.walk("right", start_game_delay)
	await get_tree().create_timer(0.4).timeout
	
	# Gracz przeskakuje nad przepaścią
	$player.jump()
	await get_tree().create_timer(start_game_delay).timeout
