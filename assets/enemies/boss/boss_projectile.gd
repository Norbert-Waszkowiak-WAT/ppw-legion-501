extends CharacterBody2D

@export var damage : float


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collision = move_and_collide(velocity)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			collider.apply_damage(damage, 10, position)
		
		$AnimatedSprite2D.play("impact")
		await $AnimatedSprite2D.animation_finished
		
		queue_free()
