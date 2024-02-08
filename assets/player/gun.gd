extends AnimatedSprite2D


@onready var sprite = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame = sprite.frame
	frame_progress = sprite.frame_progress
