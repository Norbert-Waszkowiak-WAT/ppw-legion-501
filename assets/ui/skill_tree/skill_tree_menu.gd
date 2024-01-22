extends CanvasLayer


var anim_time : float = 0.5

@onready var hud = get_node("../player/HUD")
@onready var label = get_node("MarginContainer/VBoxContainer/Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($background, "color:a", 0.3, anim_time)
	tween.tween_property($MarginContainer, "position", Vector2(0, 0), 2 * anim_time)
	if hud:
		for i in hud.get_children():
			tween.tween_property(i, "modulate:a", 0, anim_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = "Skill points: " + str(PlayerVariables.skill_points)
	
	if Input.is_action_just_pressed("skill_tree") or Input.is_action_just_pressed("escape"):
		unpause()


func unpause():
	get_parent().set_paused(false)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($background, "modulate:a", 0.0, anim_time)
	tween.tween_property($MarginContainer, "position", Vector2(0, -1080), 2 * anim_time)
	if hud:
		for i in hud.get_children():
			tween.tween_property(i, "modulate:a", 1, anim_time)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
