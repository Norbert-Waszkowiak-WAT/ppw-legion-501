extends Node2D

@onready var weapons = get_children()
@onready var player = get_node("../../../player")

var selected_weapon


# | ============================================================================= |


func _ready():
	for i in weapons:
		i.set_target("enemies")
	hide_weapons()


func _process(delta):
	get_weapon()
	if Input.is_action_just_pressed("attack") and selected_weapon:
		selected_weapon.attack(player.position)


# | ============================================================================= |


func hide_weapons():
	for i in weapons:
		i.hide()


func get_weapon():
	if Input.is_action_pressed("stick"):
		hide_weapons()
		selected_weapon = get_node("stick")
		selected_weapon.set_monitoring(true)
		selected_weapon.show()
