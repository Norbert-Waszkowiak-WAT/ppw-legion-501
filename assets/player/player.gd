extends CharacterBody2D
class_name Player


# Prędkość oraz przyspieszenie chodzenia
@export var speed: float = 40.0
@export var acceleration: float = 1.0

# Wysokość oraz prędkość skoku
@export var jump_height: float = 100.0
@export var jump_descent: float = 0.5
@export var jump_peak: float = 0.7

var queued_jump : bool = false

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
@onready var weapons = $AnimatedSprite2D/weapons.get_children()
@onready var level = get_tree().get_root().get_child(0)

var selected_weapon : Weapon

var experience : float
var exp_lvl : int
@export var MAX_EXP : float = 100.0

var damege_received: float = 0
@export var penetration_time: float = 1
var blinking_timer: float = 0


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Inicjalizuje state machine
	$state_machine.init(self)
	
	$damage_timer.timeout.connect(standard_color)
	if level is Level:
		level.pause.connect(on_paused)
	
	for i in weapons:
		i.set_target("enemies")
	hide_weapons()
	
	disable_player()
	hide()
	


# Wywoływane podczas każdej klatki
func _process(delta):
	# Wywołuje pętle state machine
	$state_machine.process(delta)
	
	# Ustawia pasek życia na aktualną wartość życia
	healthbar.value = health
	
	exp_bar_update()
	if health <= 0:
		die()
	
	process_weapons()
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
	$state_machine.change_state($state_machine/jump)


# Wymuszenie chodu gracza (do przerywników)
func walk(direction: String, duration: float):
	set_direction(direction)
	$state_machine.change_state($state_machine/walk)
	await get_tree().create_timer(duration).timeout
	$state_machine.change_state($state_machine/idle)


# Zadaje obrażenia graczowi
func apply_damage(damage, knockback, pos : Vector2):
	if $damage_timer.is_stopped():
		health -= damage
		damege_received += damage
		$damage_timer.start()
		taking_damage.emit()
		apply_knockback(knockback, pos)
		
		# Wyłącza kolizję z wrogami
		set_collision_layer_value(4, false)
		set_collision_mask_value(3, false)
		changing_color()
		

# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	taking_knockback = true
	var direction = pos.direction_to(global_position) + Vector2(0, -1.5)
	velocity = direction.normalized() * strength * knockback_multiplier


# Ustawienie koloru gracza na standardowy
func standard_color():
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1)
	
	# Wyłącza kolizję z wrogami
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true)


# Aktualizacja paska i poziomu doświadczenia
func exp_bar_update():
	if experience >= MAX_EXP:
		experience -= MAX_EXP
		exp_lvl += 1
		MAX_EXP *= 1.5
		expbar.max_value = MAX_EXP
		#Odwołanie do HUD gracza i zmiana wartości liczbowej lvl exp-a
		$HUD/level.text = str(exp_lvl)
	expbar.value = experience


func die():
	var death_menu = load("res://assets/death_menu/death_menu.tscn").instantiate()
	get_tree().get_root().get_child(0).add_child(death_menu)
	$state_machine.change_state($state_machine/idle)
	
	await $damage_timer.timeout
	set_process(false)
	set_physics_process(false)
	set_process_input(false)


#Funkcja odpowiadająca za mruganie gracza po otrzymaniu obrażeń
func changing_color():
	blinking_timer = 0.1 * $damage_timer.wait_time
	while not $damage_timer.is_stopped():
		#Zmiana koloru gracza na czerwony(RGB)
		$AnimatedSprite2D.self_modulate.a = 0.5
		
		#Program czeka czas okreslony przez zmienną "blinking_timer"
		await get_tree().create_timer(blinking_timer).timeout
		$AnimatedSprite2D.self_modulate.a = 1
		blinking_timer -= blinking_timer * 0.1
		await get_tree().create_timer(blinking_timer).timeout


func process_weapons():
	if is_processing_input():
		if Input.is_action_just_pressed("attack") and selected_weapon:
			selected_weapon.attack()
			
		if Input.is_action_pressed("stick"):
			hide_weapons()
			selected_weapon = get_node("AnimatedSprite2D/weapons/stick")
#			selected_weapon.set_monitoring(true)
			selected_weapon.show()


func hide_weapons():
	for i in weapons:
		i.hide()
		

func on_paused(value):
	if value == true:
		sprite.pause()
