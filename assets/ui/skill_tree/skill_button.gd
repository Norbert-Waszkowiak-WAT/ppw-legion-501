extends TextureButton


@export var previous_button : Node
@export var skill_name : String

@onready var line = $Line2D
@onready var popup = $PopupPanel


# Called when the node enters the scene tree for the first time.
func _ready():
	tooltip_text = skill_name + " | " + tooltip_text
	pivot_offset = size/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	line.clear_points()
	if previous_button:
		#print(str(previous_button.global_position) + " => " + str(global_position))
		line.add_point(global_position + size/2)
		line.add_point(previous_button.global_position + size/2)
