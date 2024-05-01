extends AnimatedSprite2D
class_name Weapon


# Wartości zadawanych obrażeń i odrzucenia
@export var damage: float
@export var knockback: float
@export var automatic: bool = false
@export var fire_rate: float
var attack_cooldown: float
var attack_time: float = 0.0

# Odniesienie do użytkownika broni
@onready var user = get_parent()
@onready var sprite = get_parent()


# | ============================================================================= |


func _process(delta):
	attack_cooldown = 1 / (fire_rate / 60)


func attack():
	pass
