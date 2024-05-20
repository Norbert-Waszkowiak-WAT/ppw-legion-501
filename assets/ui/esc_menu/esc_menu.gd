extends CanvasLayer

@onready var hud = get_node("../player/HUD")
@onready var buttons = $MarginContainer/VBoxContainer.find_children("*", "Button")

var exit_time : float = 0.5
var anim_time : float = 0.3

func _ready():
	set_process(false)
	$MarginContainer/VBoxContainer/resume.grab_focus()
	
	for button in buttons as Array[Button]:
		button.focus_entered.connect(_on_focus_entered)
		button.pressed.connect(_on_button_pressed)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($background, "color:a", 0.7, anim_time)
	tween.tween_property($blur.material, "shader_parameter/lod", 3, anim_time)
	tween.tween_property($MarginContainer, "position", Vector2(0, 0), 2 * anim_time)
	for i in hud.get_children():
		tween.tween_property(i, "modulate:a", 0, anim_time)
	tween.set_parallel(false)
	tween.tween_callback(set_process.bind(true))
	tween.tween_callback(Engine.set_time_scale.bind(0))
	

func _process(_delta):
	for button in buttons:
		if button.is_hovered():
			button.grab_focus()
	if Input.is_action_just_pressed("escape"):
		unpause()



func _on_main_menu_pressed():
	Engine.set_time_scale(1)
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	get_tree().change_scene_to_file("res://assets/ui/main_menu/main_menu.tscn")


func _on_restart_pressed():
	Engine.set_time_scale(1)
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	PlayerVariables.load_game(PlayerVariables.loaded_save)


func _on_exit_pressed():
	get_tree().quit()


func exit_animation():
	var tween = create_tween()
	$background.color = Color.BLACK
	$background.color.a = 0.3
	$background.z_index = 1
	tween.tween_property($background, "color:a", 1, exit_time)
	
	
func unpause():
	Engine.set_time_scale(1)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($background, "modulate:a", 0.0, anim_time)
	tween.tween_property($blur.material, "shader_parameter/lod", 0, anim_time)
	tween.tween_property($MarginContainer, "position", Vector2(0, -648), 2 * anim_time)
	for i in hud.get_children():
		tween.tween_property(i, "modulate:a", 1, anim_time)
	tween.set_parallel(false)
	tween.tween_callback(get_parent().set_paused.bind(false))
	tween.tween_callback(queue_free)


func _on_focus_entered():
	$hover_tick.play()

func _on_button_pressed():
	$select_click.play()
