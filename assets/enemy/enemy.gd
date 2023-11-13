extends CharacterBody2D
class_name Enemy


@export var speed : float
@export var acceleration : float
const GRAVITY : float = 200.0
var dir : int = 0

var health : float
@export var MAX_HEALTH : float
var taking_knockback : bool = false

@export var detection_range : float
@export var attack_range : float
@export var reaction_time : float

@export var death_time: float = 0.4

@onready var sprite = get_node("AnimatedSprite2D")
@onready var player = get_node("../player")
@onready var weapon = sprite.get_child(0)


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	weapon.set_target("player")
	health = MAX_HEALTH
	
	$healthbar.hide()
	$health_timer.timeout.connect(hide_health)


# Wywoływana na każdej klatce
func _process(delta):
	$healthbar.value = health
	if health <= 0:
		die()


func _physics_process(delta):
	# Dodanie grawitacji
	velocity.y += delta * GRAVITY
	
	# Nadanie prędkości poziomej
	if not taking_knockback and is_on_floor():
		velocity.x = dir * min(acceleration + abs(velocity.x), speed)
	else:
		taking_knockback = false
	
	# Obsługuje poruszanie i kolizję
	move_and_slide()


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


# Śmierć wroga
func die():
	sprite.self_modulate = Color(1.0, 0, 0, 1)
	await get_tree().create_timer(death_time).timeout
	queue_free()
