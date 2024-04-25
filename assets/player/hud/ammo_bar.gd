extends TextureProgressBar

@onready var player : Player = get_node("../../")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.selected_weapon is Ranged:
		show()
	else:
		hide()
	max_value = PlayerVariables.MAX_AMMO
	value = PlayerVariables.ammo
