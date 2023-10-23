extends Area2D


@export var damage: float
@export var knockback: float

@onready var user = get_parent()


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# | ============================================================================= |


func set_target(target):
	match target:
		"player":
			set_collision_mask_value(2, true)
		"enemies":
			set_collision_mask_value(3, true)
	print(get_parent(), collision_mask)


func attack(userpos):
	if $attack_timer.is_stopped():
		$stick_sprite.play("attack")
		
		var targets = get_overlapping_bodies()
		for i in targets:
			i.apply_damage(damage, knockback, userpos)
		
		$attack_timer.start()
		
		#await get_tree().create_timer(0.3).timeout
		await $attack_timer.timeout
		$stick_sprite.frame = 0
		
