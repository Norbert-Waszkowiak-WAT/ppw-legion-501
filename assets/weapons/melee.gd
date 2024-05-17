extends Weapon
class_name Melee

var queue
var exceptions = []


# | ============================================================================= |


func _ready():
	$hitbox.set_monitoring(false)


func _process(_delta):
	if $hitbox.is_monitoring():
		var targets = $hitbox.get_overlapping_bodies()
		for i in targets:
			if i not in exceptions and i.has_method("apply_damage"):
				i.apply_damage(damage, knockback, user.global_position)
				exceptions.append(i)


# Ustawia rodzaj celu dla broni (wróg, gracz, itp.)
func set_target(target):
	match target:
		"player":
			$hitbox.set_collision_mask_value(4, true)
		"enemies":
			$hitbox.set_collision_mask_value(3, true)
			$hitbox.set_collision_mask_value(5, true)


# Atak
func attack():
	if $attack_timer.is_stopped():
		if queue:
			$AnimationPlayer.play(queue)
			queue = null
		else:
			$AnimationPlayer.play("attack_1")
		
		exceptions.clear()
		$hitbox.set_monitoring(true)
		
		$attack_timer.start()
		await $attack_timer.timeout
		$hitbox.set_monitoring(false)
		
		$AnimationPlayer.play("recover")
		
	elif !queue:
		if $AnimationPlayer.current_animation == "attack_2":
			queue = "attack_1"
		else:
			queue = "attack_2"
		await $attack_timer.timeout
		attack()

