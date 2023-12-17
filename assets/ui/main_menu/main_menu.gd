extends Control


var start_game_delay : float = 1.7
var startup_delay : float = 0.9

@export var first_level : PackedScene

@onready var new_game = $MarginContainer/VBoxContainer/new_game
@onready var continue_button = $MarginContainer/VBoxContainer/continue
@onready var settings = $MarginContainer/VBoxContainer/settings
@onready var exit = $MarginContainer/VBoxContainer/exit
@onready var buttons = $MarginContainer/VBoxContainer.find_children("*", "Button")

var tween : Tween


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	startup_animation()
	#Narzuca focus sterowania klawiszami na nowa_gra


func _process(delta):
	for button in buttons:
		if button.is_hovered():
			button.grab_focus()


func _on_new_game_pressed():
	new_game_animation()
	await get_tree().create_timer(start_game_delay).timeout
	get_tree().change_scene_to_packed(first_level)


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://assets/levels/test_level/test_level.tscn")


func _on_settings_pressed():
	pass


func _on_exit_pressed():
	get_tree().quit()


# Animacja gracza po włączeniu gry
func startup_animation():
	# Wyłącza przyciski
	set_buttons_disabled(true)
	
	# Animacja przycisków w menu
	modulate = Color.BLACK
	$MarginContainer/VBoxContainer.modulate.a = 0.0
	animate()
	tween.tween_property(self, "modulate", Color.WHITE, startup_delay)
	
	# Włącza przyciski po opóźnieniu
	tween.tween_callback(set_buttons_disabled.bind(false))
	tween.tween_callback($MarginContainer/VBoxContainer/new_game.grab_focus)
	
	tween.tween_property($MarginContainer/VBoxContainer, "modulate:a", 1.0, 2 * startup_delay / 3)
	
	
	
	# Pojawienie się gracza, wyłączenie kontroli nad nim
	$player.spawn($player_spawnpoint.position)
	$player.set_process_input(false)
	# Wyłączenie kamery i interfejsu gracza
	$player/Camera2D.enabled = false
	$player/HUD.visible = false
	
	# Gracz wchodzi na ekran
	$player.walk("right", 650)


# Animacja gracza przed rozpoczęciem gry
func new_game_animation():
	# Wyłącza przyciski
	set_buttons_disabled(true)
	
	# Animacja przycisków w menu
	animate()
	tween.tween_property($MarginContainer/VBoxContainer, "modulate:a", 0.0, 2 * start_game_delay / 3)
	tween.tween_property(self, "modulate", Color.BLACK, start_game_delay / 3)
	
	# Gracz idzie w prawo
	$player.walk("right", 1700)
	await get_tree().create_timer(0.5).timeout
	
	# Gracz przeskakuje nad przepaścią
	$player.jump()


# Rozpoczyna nową animację i kończy poprzednią, jeśli istniała
func animate():
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)


# Przełącza możliwość klikania w przyciski w menu
func set_buttons_disabled(value: bool):
	for button in find_children("*", "Button", true):
		match value:
			true:
				button.focus_mode = 0
				button.set_mouse_filter(2)
			false:
				button.focus_mode = 2
				button.set_mouse_filter(0)
