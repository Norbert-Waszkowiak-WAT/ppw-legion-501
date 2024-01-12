extends TextureButton


@export var previous_button : Node
@export var ability_name : String
@export var popup_time : float
var popup_timer : float

@onready var line = $Line2D
@onready var popup = $PopupPanel
@onready var label = $RichTextLabel
@onready var ability = PlayerVariables.abilities.get(ability_name)


# Called when the node enters the scene tree for the first time.
func _ready():
	label.position += size * scale
	popup_timer = popup_time
	label.text = "[b]" + ability_name.capitalize() + " | [/b]" + tooltip_text
	pivot_offset = size/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if is_hovered():
		if popup_timer <= 0:
			label.show()
			popup_timer = popup_time
		elif !label.visible:
			popup_timer -= delta
	else:
		print("not hovered")
		label.hide()
		popup_timer = popup_time
	#popup.position = get_global_mouse_position()
	
	line.clear_points()
	if previous_button:
		line.add_point(global_position + size/2)
		line.add_point(previous_button.global_position + size/2)
