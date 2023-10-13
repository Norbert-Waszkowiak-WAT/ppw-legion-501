extends CharacterBody2D

@export var speed = 25.0
@export var acceleration = 1.0

const GRAVITY = 200.0
var dir = 0.0


# | ============================================================================= |


func _ready():
	var dir_timer = get_node("dir_timer")
	dir_timer.start()
	
	# Timer wysyła sygnał o zakończeniu liczenia, przez co aktywuje get_dir()
	dir_timer.timeout.connect(get_dir)


# | ============================================================================= |


# Obsługuje fizykę
func _physics_process(delta):
	# Dodanie grawitacji
	velocity.y += delta * GRAVITY
	
	# Nadanie prędkości poziomej
	velocity.x = dir * min(acceleration + abs(velocity.x), speed)
	
	# Obsługuje poruszanie i kolizję
	move_and_slide()


# | ============================================================================= |


# Losuje kierunek poruszania się
func get_dir():
	# Losuje float w zakresie od 0 do 1
	var chance = randf()
	
	# Zmienia kierunek oraz odwraca teksturę wroga
	if chance < 0.3:
		dir = 1.0
		scale.x = scale.y * 1
	elif chance < 0.6:
		dir = -1.0
		scale.x = scale.y * -1
	else:
		dir = 0


# | ============================================================================= |

