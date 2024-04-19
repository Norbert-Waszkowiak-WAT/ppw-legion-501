extends TextureProgressBar

var tween : Tween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlayerVariables.abilities.dash:
		show()
	else:
		hide()
	max_value = PlayerVariables.MAX_DASH_CHARGES
	if value != PlayerVariables.dash_charges:
		if !tween or !tween.is_valid():
			tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "value", PlayerVariables.dash_charges, 0.15)

