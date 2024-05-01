extends Melee


var attacking : bool = false


func _process(delta):
	if !attacking:
		animation = sprite.animation
		frame = sprite.frame
		frame_progress = sprite.frame_progress
	if !is_playing():
		play()
		
	if $hitbox.is_monitoring():
		var targets = $hitbox.get_overlapping_bodies()
		for i in targets:
			if i not in exceptions and i.has_method("apply_damage"):
				i.apply_damage(damage, knockback, user.global_position)
				exceptions.append(i)
				$impact.play()
	
	if visible and !$idle.is_playing():
		$idle.play()
	elif !visible:
		$idle.stop()

func attack():
	if !attacking:
		exceptions.clear()
		attacking = true
		
		$swing.play()
		
		animation = "attack"
		
		await frame_changed
		$hitbox.set_monitoring(true)
		
		await frame_changed
		await frame_changed
		
		$hitbox.set_monitoring(false)
		
		await animation_finished
		attacking = false
