extends Area2D
class_name Weapon


# Wartości zadawanych obrażeń i odrzucenia
@export var damage: float
@export var knockback: float

# Odniesienie do użytkownika broni
@onready var user = get_parent()


# | ============================================================================= |


func attack():
	pass
