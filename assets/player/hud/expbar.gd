extends TextureProgressBar

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	max_value = PlayerVariables.MAX_EXP
	if value != PlayerVariables.experience:
		if !tween or !tween.is_valid():
			tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "value", PlayerVariables.experience, 0.15)
