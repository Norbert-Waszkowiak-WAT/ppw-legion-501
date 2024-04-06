extends AnimatedSprite2D


@export var ghost_time : float = 0.2

var player : Player


func _ready():
	animation = player.sprite.animation
	frame = player.sprite.frame
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, ghost_time)
	await tween.finished
	queue_free()
