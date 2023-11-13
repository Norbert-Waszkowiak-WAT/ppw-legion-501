extends CharacterBody2D
class_name Player


# Prędkość oraz przyspieszenie chodzenia
@export var speed: float = 40.0
@export var acceleration: float = 1.0

# Wysokość oraz prędkość skoku
@export var jump_height: float = 100.0
@export var jump_descent: float = 0.5
@export var jump_peak: float = 0.7

# Kierunek poruszania się
var dir: float = 0.0

# Wartości życia
var health : float
@export var MAX_HEALTH: float = 100.0

var taking_knockback : bool

# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
@onready var jump_speed: float = ((2.0 * jump_height) / jump_peak) * -1
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1

# Odniesienia do potrzebnych węzłów
@onready var sprite = get_node("AnimatedSprite2D")
@onready var healthbar = get_node("HUD/healthbar")
@onready var state_machine = get_node("state_machine")


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Inicjalizuje state machine
	state_machine.init(self)
	
	$color_timer.timeout.connect(standard_color)
	disable_player()
	hide()
	

# Wywoływane podczas każdej klatki
func _process(delta):
	# Wywołuje pętle state machine
	state_machine.process(delta)
	
	# Ustawia pasek życia na aktualną wartość życia
	healthbar.value = health


# Obsługuje fizykę 
func _physics_process(delta):
	# Wywołuje pętlę fizyczną state machine
	state_machine.physics(delta)
	if taking_knockback and is_on_floor():
		taking_knockback = false


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
	health = MAX_HEALTH
	enable_player()
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
		"0":
			dir = 0


func horizontal_movement():
	if not taking_knockback:
		velocity.x = dir * min(acceleration + abs(velocity.x), speed)


# Skok
func jump():
	velocity.y = jump_speed


# Zadaje obrażenia graczowi
func apply_damage(damage, knockback, pos : Vector2):
	if $damage_timer.is_stopped():
		$AnimatedSprite2D.self_modulate = Color(1, 0, 0)
		health -= damage
		apply_knockback(knockback, pos)
		healthbar.show()
		$damage_timer.start()
		$color_timer.start()
		print("Player receives " + str(damage) + " damage.")


# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	taking_knockback = true
	var direction = pos.direction_to(position) * Vector2(2, 1) + Vector2(0, -1.5)
	velocity = direction * strength


# Ustawienie koloru gracza na standardowy
func standard_color():
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1)
