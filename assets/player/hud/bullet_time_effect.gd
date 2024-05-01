extends ColorRect

var tween : Tween


func _ready():
	material.set_shader_parameter("alpha_modifier", 0.0)

func enable():
	show()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self.material, "shader_parameter/alpha_modifier", 1.0, 0.25)


func disable():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self.material, "shader_parameter/alpha_modifier", 0.0, 0.25)
