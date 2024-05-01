extends ColorRect

@export var duration : float = 0.5
var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	material.set_shader_parameter("radius", 0.0)


func fire():
	show()
	material.set_shader_parameter("radius", 0.0)
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self.material, "shader_parameter/radius", 1.0, duration)
	await tween.finished
	hide()
