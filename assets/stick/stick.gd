extends Weapon


# Odniesienie do użytkownika broni
@onready var user = get_parent()


# | ============================================================================= |


# Ustawia rodzaj celu dla broni (wróg, gracz, itp.)
func set_target(target):
	match target:
		"player":
			set_collision_mask_value(2, true)
		"enemies":
			set_collision_mask_value(3, true)
	print(get_parent(), collision_mask)


# Atak
func attack(userpos):
	if $attack_timer.is_stopped():
		$stick_sprite.play("attack")
		
		var targets = get_overlapping_bodies()
		for i in targets:
			i.apply_damage(damage, knockback, userpos)
		
		$attack_timer.start()
		
		await $attack_timer.timeout
		$stick_sprite.frame = 0
		
