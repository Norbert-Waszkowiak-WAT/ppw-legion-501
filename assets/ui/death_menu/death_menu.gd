extends CanvasLayer

@onready var restart = get_node("MarginContainer/VBoxContainer/restart")
@onready var exit = get_node("MarginContainer/VBoxContainer/exit")
@onready var hud = get_node("../player/HUD")
@onready var buttons = $MarginContainer/VBoxContainer.find_children("*", "Button")

var exit_time : float = 1.0



func _ready():
	if get_parent().has_method("set_paused"):
		get_parent().set_paused(true)
	set_process(true)
	
	$MarginContainer/VBoxContainer/restart.grab_focus()
	
	for button in buttons as Array[Button]:
		button.focus_entered.connect(_on_focus_entered)
		button.pressed.connect(_on_button_pressed)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK)
	tween.tween_property($background, "color:a", 0.3, 1.0)
	tween.tween_property($blur.material, "shader_parameter/lod", 2, 1.0)
	tween.tween_property($MarginContainer, "position", Vector2(0, 0), 2.0)
	if hud:
		for i in hud.get_children():
			tween.tween_property(i, "modulate:a", 0, 1.0)


func _process(delta):
	for button in buttons:
		if button.is_hovered():
			button.grab_focus()


func _on_main_menu_pressed():
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	get_tree().change_scene_to_file("res://assets/ui/main_menu/main_menu.tscn")


func _on_restart_pressed():
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	PlayerVariables.load_game(PlayerVariables.loaded_save)


func _on_exit_pressed():
	get_tree().quit()


func exit_animation():
	Engine.set_time_scale(1)
	$background.color = Color.BLACK
	$background.color.a = 0.3
	$background.z_index = 1
	var tween = create_tween()
	tween.tween_property($background, "color:a", 1, exit_time)


func _on_focus_entered():
	$hover_tick.play()

func _on_button_pressed():
	$select_click.play()
