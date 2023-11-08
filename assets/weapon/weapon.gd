extends Node2D

@onready var weapons = get_children()
@onready var player = get_node("../../../player")

# Wybrana broń
var selected_weapon


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	for i in weapons:
		i.set_target("enemies")
	hide_weapons()


# Wywoływana na każdej klatce
func _process(delta):
	get_weapon()
	if Input.is_action_just_pressed("attack") and selected_weapon:
		selected_weapon.attack(player.position)


# | ============================================================================= |


# Ukrywa wszystkie sztuki broni
func hide_weapons():
	for i in weapons:
		i.hide()


# Wybór broni
func get_weapon():
	if Input.is_action_pressed("stick"):
		hide_weapons()
		selected_weapon = get_node("stick")
		selected_weapon.set_monitoring(true)
		selected_weapon.show()
