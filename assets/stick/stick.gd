extends Weapon


var queue
var exceptions = []


# | ============================================================================= |


func _process(delta):
	if is_monitoring():
		var targets = get_overlapping_bodies()
		for i in targets:
			if i not in exceptions:
				i.apply_damage(damage, knockback, user.global_position)
				exceptions.append(i)


# Ustawia rodzaj celu dla broni (wróg, gracz, itp.)
func set_target(target):
	match target:
		"player":
			set_collision_mask_value(2, true)
		"enemies":
			set_collision_mask_value(3, true)


# Atak
func attack():
	if $attack_timer.is_stopped():
		if queue:
			$AnimationPlayer.play(queue)
			queue = null
		else:
			$AnimationPlayer.play("attack_1")
		
		exceptions.clear()
		set_monitoring(true)
		
		$attack_timer.start()
		await $attack_timer.timeout
		set_monitoring(false)
		
		$AnimationPlayer.play("recover")
		
	elif !queue:
		if $AnimationPlayer.current_animation == "attack_2":
			queue = "attack_1"
		else:
			queue = "attack_2"
		await $attack_timer.timeout
		attack()
