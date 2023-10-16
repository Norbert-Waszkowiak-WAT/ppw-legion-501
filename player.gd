extends CharacterBody2D

# Prędkość oraz przyspieszenie chodzenia
@export var speed = 40.0
@export var acceleration = 1.0

# Wysokość oraz prędkość skoku
@export var jump_height = 100.0
@export var jump_descent = 0.5
@export var jump_peak = 0.7

# Kierunek poruszania się
var dir = 0.0

# Wartości życia
var health : float
@export var MAX_HEALTH = 100.0

# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
@onready var jump_speed = ((2.0 * jump_height) / jump_peak) * -1
@onready var jump_gravity = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
@onready var fall_gravity = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1

@onready var sprite = get_node("AnimatedSprite2D")
@onready var healthbar = get_node("HUD/healthbar")

# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	disable_player()
	hide()

# Wywoływane podczas każdej klatki
func _process(delta):
	# Ustawia pasek życia na aktualną wartość życia
	healthbar.value = health

# Obsługuje fizykę 
func _physics_process(delta):
	# Dodanie grawitacji
	velocity.y += get_gravity() * delta
	
	# Poruszanie się na boki
	dir = 0
	if Input.is_action_pressed("move_right"):
		set_direction("right")
	if Input.is_action_pressed("move_left"):
		set_direction("left")

	# Nadaje poziomą prędkość postaci
	velocity.x = dir * min(acceleration + abs(velocity.x), speed)


	# Granie animacji chodzenia
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
	else:
		$AnimatedSprite2D.animation = "idle"


	# Pobranie eventu jump (domyślnie spacja i strzałka w górę) oraz skok
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()


	# Obsługuje poruszanie i kolizję
	move_and_slide()


# | ============================================================================= |


# Wyłącza funkcjonalność gracza (fizyka, poruszanie się)
func disable_player():
	set_physics_process(false)
	set_process(false)


# Włącza funkcjonalność gracza
func enable_player():
	set_physics_process(true)
	set_process(true)


# Pojawianie się gracza
func spawn(pos):
	position = pos
	enable_player()
	health = MAX_HEALTH
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	show()


# Zwraca poprawną wartość grawitacji dla unoszenia się lub opadania
func get_gravity() -> float:
	if velocity.y > 0:
		return fall_gravity
	else:
		return jump_gravity


# Zmienia kierunek poruszania się i odwraca teksturę postaci
func set_direction(direction):
	# "match" to odpowiednik "switch" w GDscripcie
	match direction:
		"right":
			dir = 1.0
			sprite.scale.x = sprite.scale.y * 1
		"left":
			dir = -1.0
			sprite.scale.x = sprite.scale.y * -1


# Skok
func jump():
	velocity.y = jump_speed

