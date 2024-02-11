extends CharacterBody2D

@export var speed_of_bullet: float = 100
var damage : float
var knockback : float
var direction : float

func _ready():
	$Area2D/Shoot.play("shoot")
	velocity.x = speed_of_bullet * direction
	

func _physics_process(delta):
	for target in $Area2D.get_overlapping_bodies():
		if target is Enemy:
			target.apply_damage(damage, knockback, global_position)
		queue_free()
	
	move_and_slide()
