extends CharacterBody2D

@export var speed_of_bullet: float = 100
var direction = 1

@onready var player: Player =  get_node("../../player")

func _process(delta):
	shoot()
	
func get_direction():
	if player.dir != 0:
		direction = player.dir
	
func shoot():
	if Input.is_action_just_pressed("attack"):
		velocity.x = speed_of_bullet * direction
		if $Area2D.get_overlapping_bodies():
			print("hit")
		
