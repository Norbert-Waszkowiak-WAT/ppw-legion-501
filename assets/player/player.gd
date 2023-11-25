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
signal taking_damage

var taking_knockback : bool
@export var knockback_multiplier : float = 1.0

# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
@onready var jump_speed: float = ((2.0 * jump_height) / jump_peak) * -1
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1

# Odniesienia do potrzebnych węzłów
@onready var sprite = get_node("AnimatedSprite2D")
@onready var healthbar = get_node("HUD/healthbar")
@onready var expbar = get_node("HUD/expbar")

var experience : float
var exp_lvl : int
@export var MAX_EXP : float = 100.0


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Inicjalizuje state machine
	$state_machine.init(self)
	$damage_timer.timeout.connect(standard_color)
	disable_player()
	hide()


# Wywoływane podczas każdej klatki
func _process(delta):
	# Wywołuje pętle state machine
	$state_machine.process(delta)
	
	# Ustawia pasek życia na aktualną wartość życia
	healthbar.value = health
	
	exp_bar_update()


# Obsługuje fizykę 
func _physics_process(delta):
	# Wywołuje pętlę fizyczną state machine
	$state_machine.physics(delta)
	
	if taking_knockback and is_on_floor():
		taking_knockback = false


# | ============================================================================= |


# Wyłącza funkcjonalność gracza (fizyka, poruszanie się)
func disable_player():
	set_physics_process(false)
	set_process(false)
	set_process_input(false)
	$Camera2D.enabled = false
	$HUD.visible = false


# Włącza funkcjonalność gracza
func enable_player():
	set_physics_process(true)
	set_process(true)
	set_process_input(true)
	$Camera2D.enabled = true
	$HUD.visible = true


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


# Poruszanie się gracza w poziomie
func horizontal_movement():
	if not taking_knockback:
		velocity.x = dir * min(acceleration + abs(velocity.x), speed)


# Skok
func jump():
	velocity.y = jump_speed


# Wymuszenie chodu gracza (do przerywników)
func walk(direction: String, duration: float):
	set_direction(direction)
	$state_machine.change_state($state_machine/walk)
	await get_tree().create_timer(duration).timeout
	$state_machine.change_state($state_machine/idle)


# Zadaje obrażenia graczowi
func apply_damage(damage, knockback, pos : Vector2):
	if $damage_timer.is_stopped():
		$AnimatedSprite2D.self_modulate = Color(1, 0, 0)
		health -= damage
		apply_knockback(knockback, pos)
		$damage_timer.start()
		taking_damage.emit()


# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	taking_knockback = true
	var direction = pos.direction_to(global_position) + Vector2(0, -1.5)
	velocity = direction.normalized() * strength * knockback_multiplier


# Ustawienie koloru gracza na standardowy
func standard_color():
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1)


# Aktualizacja paska i poziomu doświadczenia
func exp_bar_update():
	if experience >= MAX_EXP:
		experience -= MAX_EXP
		exp_lvl += 1
		MAX_EXP *= 1.5
		expbar.max_value = MAX_EXP
		$HUD/level.text = str(exp_lvl)
	expbar.value = experience



