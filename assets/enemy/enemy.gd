extends CharacterBody2D
class_name Enemy


var speed : float
@export var idle_speed : float
@export var chase_speed : float
@export var acceleration : float
var dir : int = 0

var health : float
@export var MAX_HEALTH : float
var taking_knockback : bool = false

@export var dropped_experience : float = 15.0

@export var detection_range : float
@export var attack_range : float
@export var reaction_time : float
@export var memory_time : float

@export var death_time: float = 0.4

# Wysokość oraz prędkość skoku
@export var jump_height: float = 100
@export var jump_descent: float = 0.5
@export var jump_peak: float = 0.7

# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
@onready var jump_speed: float = ((2.0 * jump_height) / jump_peak) * -1
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1

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
	velocity.y += get_gravity() * delta
	
	# Nadanie prędkości poziomej
	if not taking_knockback:
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
	if result:
		return false
	else:
		return true


func get_gravity() -> float:
	if velocity.y > 0:
		return fall_gravity
	else:
		return jump_gravity


func jump():
	if is_on_floor():
		velocity.y = jump_speed


func die():
	set_process(false)
	sprite.self_modulate = Color(1.0, 0, 0, 1)
	player.experience += dropped_experience
	await get_tree().create_timer(death_time).timeout
	queue_free()
