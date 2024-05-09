extends Control


var start_game_delay : float = 1.7
var startup_delay : float = 0.9

@export var first_level : PackedScene

@onready var buttons = $MarginContainer/VBoxContainer.find_children("*", "Button")
@onready var master = $MarginContainer/VBoxContainer/settings_screen/VBoxContainer/GridContainer/Master_slider
@onready var vsync = $MarginContainer/VBoxContainer/settings_screen/VBoxContainer/GridContainer/Vsync_checkbox
@onready var gameplay = $MarginContainer/VBoxContainer/settings_screen/VBoxContainer/GridContainer/Gameplay_slider
@onready var display = $MarginContainer/VBoxContainer/settings_screen/VBoxContainer/GridContainer/Display_dropdown
@onready var menu = $MarginContainer/VBoxContainer/settings_screen/VBoxContainer/GridContainer/Menu_slider


var tween : Tween


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	load_settings()
	startup_animation()
	for button in buttons as Array[Button]:
		button.focus_entered.connect(_on_focus_entered)


func _process(_delta):
	for button in buttons as Array[Button]:
		if button.is_hovered() and !button.disabled:
			button.grab_focus()


func _on_focus_entered():
	$hover_tick.play()


func _on_new_game_pressed():
	$MarginContainer/VBoxContainer/main_screen.hide()
	$MarginContainer/VBoxContainer/new_game_screen.show()


func start_new_game():
	new_game_animation()
	await get_tree().create_timer(start_game_delay).timeout
	get_tree().change_scene_to_packed(first_level)


func _on_continue_pressed():
	$MarginContainer/VBoxContainer/main_screen.hide()
	$MarginContainer/VBoxContainer/load_screen.show()


func _on_settings_pressed():
	$MarginContainer/VBoxContainer/main_screen.hide()
	$MarginContainer/VBoxContainer/settings_screen.show()


func _on_exit_pressed():
	get_tree().quit()


func _on_back_pressed():
	$MarginContainer/VBoxContainer/load_screen.hide()
	$MarginContainer/VBoxContainer/new_game_screen.hide()
	$MarginContainer/VBoxContainer/settings_screen.hide()
	$MarginContainer/VBoxContainer/main_screen.show()


# Animacja gracza po włączeniu gry
func startup_animation():
	set_process(false)
	# Wyłącza przyciski
	set_buttons_disabled(true)
	
	# Animacja przycisków w menu
	modulate = Color.BLACK
	$MarginContainer/VBoxContainer.modulate.a = 0.0
	animate()
	tween.tween_property(self, "modulate", Color.WHITE, startup_delay)
	
	# Włącza przyciski po opóźnieniu
	tween.tween_callback(set_buttons_disabled.bind(false))
	if $MarginContainer/VBoxContainer/main_screen/new_game:
		tween.tween_callback($MarginContainer/VBoxContainer/main_screen/new_game.grab_focus)
	
	tween.tween_property($MarginContainer/VBoxContainer, "modulate:a", 1.0, 2 * startup_delay / 3)
	tween.tween_callback(set_process.bind(true))
	
	
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
	set_process(false)
	
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


func _on_vsync_checkbox_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)



func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)


func _on_menu_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)


func _on_gameplay_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, value)


func _on_display_dropdown_item_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func save_settings():
	var file = FileAccess.open("user://user_settings.settings", FileAccess.WRITE)
	var settings = {
		"master" : master.value,
		"vsync" : vsync.button_pressed,
		"gameplay" : gameplay.value,
		"display" : display.selected,
		"menu" : menu.value
	}
	file.store_var(settings)


func load_settings():
	if !FileAccess.file_exists("user://user_settings.settings"):
		return
	var file = FileAccess.open("user://user_settings.settings", FileAccess.READ)
	var settings = file.get_var()
	master.value = settings["master"]
	vsync.button_pressed = settings["vsync"]
	gameplay.value = settings["gameplay"]
	display.selected = settings["display"]
	menu.value = settings["menu"]


func _on_save_pressed():
	save_settings()
