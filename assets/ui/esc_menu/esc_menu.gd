extends CanvasLayer

@onready var hud = get_node("../player/HUD")
@onready var buttons = $MarginContainer/VBoxContainer.find_children("*", "Button")

var exit_time : float = 1.0
var anim_time : float = 0.5

func _ready():
	set_process(true)
	
	$MarginContainer/VBoxContainer/resume.grab_focus()
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK)
	tween.tween_property($background, "color:a", 0.3, anim_time)
	tween.tween_property($MarginContainer, "position", Vector2(0, 0), 2 * anim_time)
	for i in hud.get_children():
		tween.tween_property(i, "modulate:a", 0, anim_time)
	

func _process(delta):
	for button in buttons:
		if button.is_hovered():
			button.grab_focus()
	if Input.is_action_just_pressed("escape"):
		unpause()



func _on_main_menu_pressed():
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	get_tree().change_scene_to_file("res://assets/ui/main_menu/main_menu.tscn")


func _on_restart_pressed():
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	get_tree().reload_current_scene()


func _on_exit_pressed():
	get_tree().quit()


func exit_animation():
	var tween = create_tween()
	$background.color = Color.BLACK
	$background.color.a = 0.3
	$background.z_index = 1
	tween.tween_property($background, "color:a", 1, exit_time)
	
	
func unpause():
	get_parent().set_paused(false)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($background, "modulate:a", 0.0, anim_time)
	tween.tween_property($MarginContainer, "position", Vector2(0, -648), 2 * anim_time)
	for i in hud.get_children():
		tween.tween_property(i, "modulate:a", 1, anim_time)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
