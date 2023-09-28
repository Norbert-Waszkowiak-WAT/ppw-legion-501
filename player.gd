extends CharacterBody2D

@export var speed = 40.0
@export var jump_height = 100.0
@export var jump_descent = 0.5
@export var jump_peak = 0.7

# Wartości prędkości na podstawie równania rzutu pionowego
var jump_speed = ((2.0 * jump_height) / jump_peak) * -1
var jump_gravity = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
var fall_gravity = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1

# | ============================================================================= |

# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello world")
	
	jump_speed = ((2.0 * jump_height) / jump_peak) * -1
	jump_gravity = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
	fall_gravity = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1


# Obsługuje fizykę 
func _physics_process(delta):
	# Dodanie grawitacji
	velocity.y += get_gravity() * delta
	
	# Poruszanie się na boki
	var input_dir = 0.0
	if Input.is_action_pressed("move_right"):
		input_dir += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir += -1.0
	velocity.x = input_dir * speed
	
	# Pobranie eventu jump (domyślnie spacja i strzałka w górę) oraz skok
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	# Obsługuje poruszanie i kolizję
	move_and_slide()

# | ============================================================================= |

# Zwraca poprawną wartość grawitacji dla unoszenia się lub opadania
func get_gravity() -> float:
	if velocity.y > 0:
		return fall_gravity
	else:
		return jump_gravity

# Skok
func jump():
	velocity.y = jump_speed
