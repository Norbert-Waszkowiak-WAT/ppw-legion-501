extends TextureButton


@export var previous_button : Node

@onready var line = $Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if previous_button:
		print(str(previous_button.global_position) + " => " + str(global_position))
		line.add_point(position + size/2)
		line.add_point(previous_button.position + previous_button.size/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
