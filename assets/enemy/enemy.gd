extends CharacterBody2D
class_name Enemy


var speed : float
@export var idle_speed : float
@export var chase_speed : float
@export var acceleration : float
const GRAVITY : float = 200.0
var dir : int = 0

var health : float
@export var MAX_HEALTH : float
var taking_knockback : bool = false

@export var dropped_experience : float = 15.0

@export var detection_range : float
@export var attack_range : float
@export var reaction_time : float

@export var death_time: float = 0.4

@onready var sprite = get_node("AnimatedSprite2D")
@onready var player = get_node("../player")
@onready var weapon = sprite.find_children("*", "Weapon")[0]


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	if weapon:
		weapon.set_target("player")
	health = MAX_HEALTH
	
	$healthbar.max_value = MAX_HEALTH
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
#		print("Enemy receives " + str(damage) + " damage.")


# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	taking_knockback = true
	var direction = pos.direction_to(position) + Vector2(0, -1.5)
	velocity = direction * strength
	print(velocity)


# Ukrywa pasek życia po określonym czasie
func hide_health():
	$healthbar.hide()
	$health_timer.stop()


func sees_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.position, 1)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result or position.direction_to(player.position).x * sprite.scale.x < 0:
		return false
	else:
		return true

func die():
	set_process(false)
	sprite.self_modulate = Color(1.0, 0, 0, 1)
	player.experience += dropped_experience
	await get_tree().create_timer(death_time).timeout
	queue_free()
