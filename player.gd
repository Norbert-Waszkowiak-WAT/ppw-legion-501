extends CharacterBody2D

@export var speed = 40.0
@export var acceleration = 1.0

@export var jump_height = 100.0
@export var jump_descent = 0.5
@export var jump_peak = 0.7

var jump_speed
var jump_gravity
var fall_gravity

var dir = 0.0

# | ============================================================================= |

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemy = get_node("Level/enemy")
	enemy.hit.connect(on_received_hit)
	
	# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
	jump_speed = ((2.0 * jump_height) / jump_peak) * -1
	jump_gravity = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
	fall_gravity = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1


# Obsługuje fizykę 
func _physics_process(delta):
	# Dodanie grawitacji
	velocity.y += get_gravity() * delta
	
	dir = 0
	
	# Poruszanie się na boki
	if Input.is_action_pressed("move_right"):
		set_direction("right")
	if Input.is_action_pressed("move_left"):
		set_direction("left")
		
	velocity.x = dir * min(acceleration + abs(velocity.x), speed)
	
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

# Zmienia kierunek poruszania się postaci
func set_direction(direction):
	match direction:
		"right":
			dir = 1.0
			scale.x = scale.y * 1
		"left":
			dir = -1.0
			scale.x = scale.y * -1

func on_received_hit():
	print("hit!")

# Skok
func jump():
	velocity.y = jump_speed
