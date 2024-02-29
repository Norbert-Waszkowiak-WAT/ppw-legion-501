extends Area2D

signal level_completed


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_overlapping_bodies():
		level_completed.emit()
		set_process(false)
