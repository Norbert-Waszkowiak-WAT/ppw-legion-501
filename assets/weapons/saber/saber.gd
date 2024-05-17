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
			if i not in exceptions and i is EnemyProjectile:
				if PlayerVariables.abilities.deflect:
					i.direction *= -1
					i.set_collision_mask_value(2, false)
					i.set_collision_mask_value(3, true)
					i.get_node("Area2D").set_collision_mask_value(2, false)
					i.get_node("Area2D").set_collision_mask_value(3, true)
				elif PlayerVariables.abilities.block:
					i.impact()
				exceptions.append(i)
	
	if PlayerVariables.abilities.force_push:
		knockback = 45
	else:
		knockback = 35
	if PlayerVariables.abilities.enhanced_plasma:
		damage = 30
	else:
		damage = 20
	if PlayerVariables.abilities.low_resistance_blade:
		sprite_frames.set_animation_speed("attack", 20)
	else:
		sprite_frames.set_animation_speed("attack", 17)
	
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
	else:
		await animation_finished
		attack()
