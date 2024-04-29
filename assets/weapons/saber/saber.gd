extends Melee


func attack():
	exceptions.clear()
	
	play("attack")
	$hitbox.set_monitoring(true)
	
	await animation_finished
	
	$hitbox.set_monitoring(false)
