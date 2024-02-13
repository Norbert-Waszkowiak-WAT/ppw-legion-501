extends CharacterBody2D

@export var speed_of_bullet: float = 100
var damage : float
var knockback : float
var direction : float

@onready var sprite = get_node("Area2D/AnimatedSprite2D")



func _ready():
	velocity.x = speed_of_bullet * direction
	

func _physics_process(delta):
	for target in $Area2D.get_overlapping_bodies():
		set_physics_process(false)
		if target is Enemy:
			target.apply_damage(damage, knockback, global_position)
		sprite.play("hit")
		await sprite.animation_finished
		queue_free()
	
	move_and_slide()
