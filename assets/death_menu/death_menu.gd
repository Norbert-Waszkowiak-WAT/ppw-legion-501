extends CanvasLayer

@onready var restart = get_node("MarginContainer/VBoxContainer/restart")
@onready var exit = get_node("MarginContainer/VBoxContainer/exit")
@onready var hud = get_node("../player/HUD")

var exit_time : float = 1.0



func _ready():
	get_parent().set_paused(true)
	$MarginContainer/VBoxContainer/restart.grab_focus()
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK)
	tween.tween_property($background, "modulate:a", 0.3, 1.0)
	tween.tween_property($MarginContainer, "position", Vector2(0, 0), 2.0)
	for i in hud.get_children():
		tween.tween_property(i, "modulate:a", 0, 1.0)


func _on_main_menu_pressed():
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	get_tree().change_scene_to_file("res://assets/main_menu/main_menu.tscn")


func _on_restart_pressed():
	exit_animation()
	await get_tree().create_timer(exit_time).timeout
	get_tree().reload_current_scene()


func _on_exit_pressed():
	get_tree().quit()


func exit_animation():
	var tween = create_tween()
	tween.tween_property($tint, "color:a", 1, exit_time)
