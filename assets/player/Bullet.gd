extends CharacterBody2D

@export var speed_of_bullet: float = 100
var direction = 1

@onready var player: Player =  get_node("../../../../player")

func _physics_process(delta):
	get_direction()
	shoot()
	
func get_direction():
	if player.dir != 0:
		direction = player.dir
	
func shoot():
	print("!")
	$Area2D/Shoot.play("shoot")
	velocity.x = speed_of_bullet * direction
	if $Area2D.get_overlapping_bodies():
		print("hit")
		_physics_process(false)
		
