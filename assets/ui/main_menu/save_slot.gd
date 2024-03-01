extends Button


@export var file_index : String


func _ready():
	if FileAccess.file_exists("user://save_slot_" + file_index + ".save"):
		text = "save " + file_index
	else:
		text = "slot " + file_index
		if get_parent().get_parent().name == "load_screen":
			disabled = true
			focus_mode = Control.FOCUS_NONE


func _on_pressed():
	if get_parent().get_parent().name == "load_screen":
		PlayerVariables.load_game(file_index)
	elif get_parent().get_parent().name == "new_game_screen":
		PlayerVariables.reset_player()
		PlayerVariables.loaded_save = file_index
		get_tree().get_root().get_node("main_menu").start_new_game()
