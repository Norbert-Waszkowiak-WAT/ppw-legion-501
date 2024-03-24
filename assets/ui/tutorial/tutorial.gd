extends CanvasLayer


@export var titles : Array[String]
@export_multiline var instructions : Array[String]

var tween : Tween

var showing: bool = false

@onready var title = get_node("Panel/MarginContainer/VBoxContainer/Label")
@onready var instruction = get_node("Panel/MarginContainer/VBoxContainer/RichTextLabel")


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	


func show_tutorial(page_index : int):
	enter_animation()
	title.text = titles[page_index]
	instruction.text = instructions[page_index]


func hide_tutorial():
	exit_animation()


func animate():
	if tween:
		tween.kill()
	tween = create_tween()


func enter_animation():
	show()
	$Panel.scale = Vector2(0.001, 0.005)
	animate()
	tween.set_parallel(false).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Panel, "scale:x", 1, 0.1)
	tween.tween_property($Panel, "scale:y", 1, 0.1)


func exit_animation():
	animate()
	tween.set_parallel(false).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Panel, "scale:y", 0.005, 0.1)
	tween.tween_property($Panel, "scale:x", 0.001, 0.1)
	tween.tween_callback(hide)
