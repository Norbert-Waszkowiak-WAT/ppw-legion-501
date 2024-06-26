extends CharacterBody2D
class_name Enemy


# Movement
var speed : float
@export var idle_speed : float
@export var chase_speed : float
@export var acceleration : float
var dir : int = 0

# życie
var health : float
@export var MAX_HEALTH : float
var is_dead : bool = false
var taking_knockback : bool = false
var knockback_multiplier : float = 1.7

# Doświadczenie
@export var dropped_experience : float

# Zasięg
@export var detection_range : float
@export var attack_range : float

# Stany
enum states {idle, chase, attack}
var current_state : states
var starting_state : states = states.idle

# Wysokość oraz prędkość skoku
@export var jump_height: float = 100
@export var jump_descent: float = 0.5
@export var jump_peak: float = 0.7

# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
@onready var jump_speed: float = ((2.0 * jump_height) / jump_peak) * -1
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1


# ----| Timery |----

@export var reaction_time : float
var reaction_timer : float

@export var memory_time : float
var memory_timer : float

@export var attack_time : float
var attack_timer : float

var dir_time : float = 2.0
var dir_timer : float

@export var death_time: float = 0.4


# ----| Odniesienia |----

@onready var sprite = get_node("AnimatedSprite2D")
@onready var player = get_tree().get_root().find_child("player", true, false)
@onready var weapon = sprite.find_children("*", "Weapon")[0]


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	is_dead = false
	change_state(starting_state)
	speed = idle_speed
	
	if weapon:
		weapon.set_target("player")
	health = MAX_HEALTH
	
	$healthbar.max_value = MAX_HEALTH
	$healthbar.hide()
	$health_timer.timeout.connect(hide_health)
	
	# Daje wrogowi znać, jak wysoko może doskoczyć
	$right_wall.position.y = -jump_height + 6
	$left_wall.position.y = -jump_height + 6


# Wywoływana na każdej klatce
func _process(_delta):
	$healthbar.value = health
	if health <= 0:
		die()


func _physics_process(delta):
	if !is_dead:
		match current_state:
			states.idle:
				idle(delta)
			states.chase:
				chase(delta)
			states.attack:
				attack(delta)
		check_movement()
		# Nadanie prędkości poziomej
		if not taking_knockback:
			velocity.x = dir * min(acceleration + abs(velocity.x), speed)
	
	# Dodanie grawitacji
	velocity.y += get_gravity() * delta
	
	# Obsługuje poruszanie i kolizję
	move_and_slide()
	
	if taking_knockback and is_on_floor():
		taking_knockback = false


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
	velocity = direction * strength * knockback_multiplier


# Ukrywa pasek życia po określonym czasie
func hide_health():
	$healthbar.hide()
	$health_timer.stop()


# Zwraca true, jeśli bezpośrenio widzi gracza
func sees_player() -> bool:
	if not PlayerVariables.health <= 0:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, player.position, 1)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if result:
			return false
		else:
			return true
	else:
		return false


func get_gravity() -> float:
	if velocity.y > 0:
		return fall_gravity
	else:
		return jump_gravity


# Losuje kierunek poruszania się
func get_dir():
	# Losuje float w zakresie od 0 do 1
	var chance = randf()
	
	# Zmienia kierunek oraz odwraca teksturę wroga
	if chance < 0.3:
		dir = 1
		sprite.scale.x = sprite.scale.y * 1
	elif chance < 0.6:
		dir = -1
		sprite.scale.x = sprite.scale.y * -1
	else:
		dir = 0


# Zmiana stanu
func change_state(state : states):
	if state != current_state:
		#print(str(current_state) + " -> " + str(state))
		reaction_timer = reaction_time
		current_state = state


# Odpowiada za zachowanie wroga poza walką
func idle(delta: float):
	if reaction_timer <= 0:
		speed = idle_speed
		dir_timer -= delta
		if dir_timer <= 0:
			dir_timer = dir_time
			get_dir()
	else:
		reaction_timer -= delta
	
	if position.distance_to(player.position) <= detection_range and sees_player():
		speed = chase_speed
		change_state(states.chase)
	if position.distance_to(player.position) <= attack_range and sees_player():
		attack_timer = 0
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczas gonienia gracza
func chase(delta: float):
	if reaction_timer <= 0:
		speed = chase_speed
		turn_towards_player()
	else:
		reaction_timer -= delta
	
	if position.distance_to(player.position) > detection_range or !sees_player():
		if memory_timer <= 0:
			memory_timer = memory_time
			change_state(states.idle)
		else:
			memory_timer -= delta
		
	if position.distance_to(player.position) <= attack_range:
		attack_timer = 0
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczes ataku
func attack(delta: float):
	if reaction_timer <= 0:
		turn_towards_player()
		if attack_timer <= 0:
			weapon.attack()
			attack_timer = attack_time
		attack_timer -= delta
	else:
		reaction_timer -= delta
	
	
	if position.distance_to(player.position) > detection_range or !sees_player():
		if memory_timer <= 0:
			memory_timer = memory_time
			change_state(states.idle)
		else:
			memory_timer -= delta
	if position.distance_to(player.position) > attack_range:
		change_state(states.chase)


func check_movement():
	match current_state:
		states.chase:
			if (!$left_long.get_collider() and dir == -1) or (!$right_long.get_collider() and dir == 1):
				jump()
			if $left_step.get_collider() and !$left_wall.get_collider() and dir == -1:
				jump()
			elif !$left_short.get_collider() and dir == -1 and !$left_wall.get_collider() and player.position.y < position.y:
				jump()
			if $right_step.get_collider() and !$right_wall.get_collider() and dir == 1:
				jump()
			elif !$right_short.get_collider() and dir == 1 and !$right_wall.get_collider() and player.position.y < position.y:
				jump()
		states.idle:
			if !$left_short.get_collider() and dir == -1 and is_on_floor():
				dir = 0
			if !$right_short.get_collider() and dir == 1 and is_on_floor():
				dir = 0


func turn_towards_player():
	if position.x > player.position.x - 10 and position.x < player.position.x + 10:
		dir = 0
	elif position.direction_to(player.position).x > 0:
		dir = 1
		sprite.scale.x = sprite.scale.y * dir
	else:
		dir = -1
		sprite.scale.x = sprite.scale.y * dir


func jump():
	if is_on_floor():
		velocity.y = jump_speed


func die():
	set_process(false)
	is_dead = true
	sprite.self_modulate = Color(1.0, 0, 0, 1)
	PlayerVariables.experience += dropped_experience
	await get_tree().create_timer(death_time).timeout
	queue_free()
