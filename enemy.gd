extends CharacterBody2D

@export var speed = 25.0
@export var acceleration = 1.5

const GRAVITY = 200.0
var dir = 0.0

var health : float
@export var MAX_HEALTH = 100.0

var taking_knockback = false

@onready var sprite = get_node("Enemy")
@onready var dir_timer = get_node("dir_timer")
@onready var player = get_node("../player")
@onready var weapon = $Enemy.get_children()[0]


# | ============================================================================= |


func _ready():
	dir_timer.start()
	$healthbar.hide()
	health = MAX_HEALTH
	
	# Timer wysyła sygnał o zakończeniu liczenia, przez co aktywuje get_dir()
	dir_timer.timeout.connect(get_dir)
	$health_timer.timeout.connect(hide_health)
	
	weapon.set_target("player")
	weapon.set_monitoring(true)


# | ============================================================================= |


func _process(delta):
	$healthbar.value = health


# Obsługuje fizykę
func _physics_process(delta):
	# Dodanie grawitacji
	velocity.y += delta * GRAVITY
	
	# Nadanie prędkości poziomej
	if not taking_knockback and is_on_floor():
		velocity.x = dir * min(acceleration + abs(velocity.x), speed)
	else:
		taking_knockback = false
	
	weapon.attack(position)
	
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
		sprite.scale.x = sprite.scale.y * 1
	elif chance < 0.6:
		dir = -1.0
		sprite.scale.x = sprite.scale.y * -1
	else:
		dir = 0


# Zadaje obrażenia oraz pokazuje pasek życia
func apply_damage(damage, knockback, pos : Vector2):
	if $damage_timer.is_stopped():
		health -= damage
		apply_knockback(knockback, pos)
		$healthbar.show()
		$health_timer.start()
		$damage_timer.start()
		print("Enemy receives " + str(damage) + " damage.")


# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	taking_knockback = true
	var direction = pos.direction_to(position) + Vector2(0, -1.5)
	velocity = direction * strength
	

# Ukrywa pasek życia po określonym czasie
func hide_health():
	$healthbar.hide()
	$health_timer.stop()


# | ============================================================================= |

