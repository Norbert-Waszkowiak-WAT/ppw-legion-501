extends AnimatedSprite2D




# Ustawia rodzaj celu dla broni (wróg, gracz, itp.)
func set_target(target):
	match target:
		"player":
			$Area2D.set_collision_mask_value(4, true)
		"enemies":
			$Area2D.set_collision_mask_value(3, true)
