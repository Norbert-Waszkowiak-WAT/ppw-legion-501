extends CharacterBody2D

@export var speed : float = 25.0
@export var acceleration : float = 1.5
const GRAVITY : float = 200.0
var dir : int = 0


var health : float
@export var MAX_HEALTH: float = 100.0
var taking_knockback: bool = false
@export var death_time: float = 0.4


enum states {idle, chase, attack}
var current_state : states


@export var detection_range : float
@export var attack_range : float
@export var reaction_time : float


@onready var sprite = get_node("Enemy")
@onready var player = get_node("../player")
@onready var weapon = $Enemy.get_child(0)


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	current_state = states.idle
	
	$dir_timer.timeout.connect(get_dir)
	$dir_timer.start()
	
	$healthbar.hide()
	$health_timer.timeout.connect(hide_health)
	health = MAX_HEALTH
	
	# Ustawia cel broni na gracza
	weapon.set_target("player")
	weapon.set_monitoring(true)


# Wywoływana na każdej klatce
func _process(delta):
	$healthbar.value = health
	
	if health <= 0:
		die()


# Obsługuje fizykę
func _physics_process(delta):
	
	match current_state:
		states.idle:
			idle()
		states.chase:
			chase()
		states.attack:
			attack()
	# Dodanie grawitacji
	velocity.y += delta * GRAVITY
	
	# Nadanie prędkości poziomej
	if not taking_knockback and is_on_floor():
		velocity.x = dir * min(acceleration + abs(velocity.x), speed)
	else:
		taking_knockback = false
	
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


func change_state(state : states):
	await get_tree().create_timer(reaction_time).timeout
	current_state = state

# Odpowiada za zachowanie wroga poza walką
func idle():
	$dir_timer.start
	
	if position.distance_to(player.position) <= detection_range:
		$dir_timer.stop
		change_state(states.chase)
	if position.distance_to(player.position) <= attack_range:
		$dir_timer.stop
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczas gonienia gracza
func chase():
	if position.direction_to(player.position).x > 0:
		dir = 1
	else:
		dir = -1
	sprite.scale.x = sprite.scale.y * dir
	
	if position.distance_to(player.position) > detection_range:
		change_state(states.idle)
	if position.distance_to(player.position) <= attack_range:
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczes ataku
func attack():
	dir = 0
	weapon.attack(position)
	
	if position.distance_to(player.position) > detection_range:
		change_state(states.idle)
	if position.distance_to(player.position) <= detection_range:
		change_state(states.chase)


# Ukrywa pasek życia po określonym czasie
func hide_health():
	$healthbar.hide()
	$health_timer.stop()


# Śmierć wroga
func die():
	$Enemy.self_modulate = Color(1.0, 0, 0, 1)
	set_collision_layer_value(3, false)
	await get_tree().create_timer(death_time).timeout
	queue_free()


# | ============================================================================= |

