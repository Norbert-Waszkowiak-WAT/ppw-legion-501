extends CharacterBody2D
class_name Enemy


# Movement
var speed : float
@export var idle_speed : float
@export var chase_speed : float
@export var acceleration : float
var dir : int = 0
var in_movement : bool = false
var path = {}

# życie
var health : float
@export var MAX_HEALTH : float
var is_dead : bool = false
var taking_knockback : bool = false
var knockback_multiplier : float = 1.7

# Doświadczenie
@export var dropped_experience : float
@export var dropped_ammo := 5

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

var dir_time : float = 2.0
var dir_timer : float

@export var death_time: float = 0.4


# ----| Odniesienia |----

@onready var sprite = get_node("AnimatedSprite2D")
@onready var player = get_tree().get_root().find_child("player", true, false)
@onready var weapon = sprite.find_children("*", "Weapon")[0]
@onready var terrain = get_node("../terrain")


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	is_dead = false
	change_state(starting_state)
	speed = idle_speed
	sprite.animation = "idle"
	
	randomize_stats()
	
	if weapon is Melee:
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
		
	if is_on_floor():
		#$navigation_component.calculate_trajectory(delta, dir, global_position)
		pass
	
	if dir != 0:
		sprite.scale.x = sprite.scale.y * dir
	
	if velocity.y > 0:
		sprite.animation = "fall"
	elif velocity.y < 0:
		sprite.animation = "jump"
	elif velocity.x != 0:
		sprite.animation = "walk"
	else:
		sprite.animation = "idle"
	
	if !sprite.is_playing():
		sprite.play()


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
			#velocity.x = dir * min(acceleration + abs(velocity.x), speed)
			velocity.x = dir * speed
	
	# Dodanie grawitacji
	velocity.y += get_gravity() * delta
	
	# Obsługuje poruszanie i kolizję
	move_and_slide()
	
	if taking_knockback and is_on_floor():
		taking_knockback = false


func randomize_stats():
	randomize()
	idle_speed = idle_speed * randf_range(0.85, 1.15)
	#chase_speed = chase_speed * randf_range(1, 1.1)
	attack_range = attack_range * randf_range(0.85, 1.05)
	reaction_time = reaction_time  * randf_range(0.85, 1.15)


# Zadaje obrażenia oraz pokazuje pasek życia
func apply_damage(damage, knockback, pos : Vector2):
	health -= damage
	apply_knockback(knockback, pos)
	$healthbar.show()
	$health_timer.start()


# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	if strength != 0:
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
	
	$navigation_timer.stop()
	
	if position.distance_to(player.position) <= detection_range and sees_player():
		update_path()
		change_state(states.chase)
	if position.distance_to(player.position) <= attack_range and sees_player():
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczas gonienia gracza
func chase(delta: float):
	if reaction_timer <= 0:
		speed = chase_speed
	else:
		reaction_timer -= delta
	
	if $navigation_timer.is_stopped():
		$navigation_timer.start()
	
	if position.distance_to(player.position) > detection_range or !sees_player():
		if memory_timer <= 0:
			memory_timer = memory_time
			change_state(states.idle)
		else:
			memory_timer -= delta
	else:
		memory_timer = memory_time
		
	if position.distance_to(player.position) <= attack_range:
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczes ataku
func attack(delta: float):
	if reaction_timer <= 0:
		turn_towards_player()
		speed = 0
		weapon.attack()
	else:
		reaction_timer -= delta
	
	$navigation_timer.stop()
	
	if position.distance_to(player.position) > detection_range or !sees_player():
		if memory_timer <= 0:
			memory_timer = memory_time
			change_state(states.idle)
		else:
			memory_timer -= delta
	else:
		memory_timer = memory_time
	if position.distance_to(player.position) > attack_range:
		change_state(states.chase)


func check_movement():
	match current_state:
		states.chase:
			if path.size() > 1 and !in_movement and is_on_floor():
				var waypoint = $navigation_component.map_to_global(path[1][0])
				var action = path[0][1]
				var distance = abs(waypoint.x - global_position.x)
				
				if action == "walk_right":
					walk(distance, 1, chase_speed)
				elif action == "jump_right":
					jump()
					walk(distance, 1, chase_speed)
				elif action == "jump_slow_right":
					jump()
					walk(distance, 1, chase_speed / 4)
				
				if action == "walk_left":
					walk(distance, -1, chase_speed)
				elif action == "jump_left":
					jump()
					walk(distance, -1, chase_speed)
				elif action == "jump_slow_left":
					jump()
					walk(distance, -1, chase_speed / 4)
				
				path.remove_at(0)
			if path.size() == 1:
				path = []
				if $navigation_timer.wait_time != 0.05:
					$navigation_timer.wait_time = 0.05
			elif path.size() > 1 and $navigation_timer.wait_time != 0.2:
				$navigation_timer.wait_time = 0.2

		states.idle:
			if !$left_short.get_collider() and dir == -1 and is_on_floor():
				dir = 0
			if !$right_short.get_collider() and dir == 1 and is_on_floor():
				dir = 0


func turn_towards_player():
	if global_position.x > player.global_position.x - 5 and global_position.x < player.global_position.x + 5:
		dir = 0
	elif global_position.direction_to(player.global_position).x > 0:
		dir = 1
	else:
		dir = -1


func walk(distance : float, direction : int, current_speed : float):
	speed = current_speed
	var duration = distance / current_speed
	
	in_movement = true
	dir = direction
	await get_tree().create_timer(duration).timeout
	dir = 0
	in_movement = false


func jump():
	if is_on_floor():
		velocity.y = jump_speed


func update_path():
	if is_on_floor():
		var destination = $navigation_component.global_to_map(player.global_position) + Vector2i(0, 1)
		var working_path = $navigation_component.A_Star($navigation_component.global_to_map(global_position), destination)
		if not working_path.is_empty():
			path = working_path
		elif $navigation_timer.wait_time != 1:
			$navigation_timer.wait_time = 1


func die():
	set_process(false)
	is_dead = true
	sprite.modulate = Color(1.0, 0, 0, 1)
	PlayerVariables.experience += dropped_experience
	PlayerVariables.ammo += dropped_ammo
	await get_tree().create_timer(death_time).timeout
	queue_free()
