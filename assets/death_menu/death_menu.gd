extends Control

@onready var restart = get_node("MarginContainer/VBoxContainer/restart")
@onready var exit = get_node("MarginContainer/VBoxContainer/exit")

func _ready():
	$MarginContainer/VBoxContainer/restart.grab_focus()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://assets/main_menu/main_menu.tscn")


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://assets/test_level/test_level.tscn")


func _on_exit_pressed():
	get_tree().quit()
