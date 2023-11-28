extends AnimatedSprite2D

@export var heal: float = 50
@export var heal_timer: float = 5
@onready var player: Player =  get_node("../player")

func _ready():
	animation = "full"
	play()


func _process(delta):
	health_restoring()


func health_restoring():
	if $Area2D.get_overlapping_bodies() and animation == "full":
		animation = "empty"
		play()
		if player.health <= player.MAX_HEALTH - player.health:
			player.health += heal
		else:
			player.health += player.MAX_HEALTH - player.health
		await get_tree().create_timer(heal_timer).timeout
		animation = "full"
		play()
		
		
