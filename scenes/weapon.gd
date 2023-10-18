extends Node2D

@onready var weapons = get_children()
@onready var player = get_node("../../../player")

var selected_weapon


# | ============================================================================= |


func _ready():
	hide_weapons()


func _process(delta):
	get_weapon()
	if Input.is_action_just_pressed("attack"):
		if selected_weapon == "stick":
			$stick.rotation += 90
			
			var targets = $stick.get_overlapping_bodies()
			for i in targets:
				pass
				i.apply_damage(10, 35, player.position)
				
			await get_tree().create_timer(0.3).timeout
			
			$stick.rotation -= 90



# | ============================================================================= |


func hide_weapons():
	get_tree().call_group("weapons", "hide")
	get_tree().call_group("weapons", "set_monitoring(false)")


func get_weapon():
	if Input.is_action_pressed("stick"):
		hide_weapons()
		selected_weapon = "stick"
		$stick.set_monitoring(true)
		$stick.show()
