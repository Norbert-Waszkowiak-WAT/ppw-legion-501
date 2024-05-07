extends CharacterBody2D
class_name Player


# Prędkość oraz przyspieszenie chodzenia
@export var speed: float = 40.0
@export var acceleration: float = 1.0
var speed_modifier : float = 1.0
var accel_modifier : float = 1.0

# Wysokość oraz prędkość skoku
@export var jump_height: float = 100.0
@export var jump_descent: float = 0.5
@export var jump_peak: float = 0.7

var queued_jump : bool = false

var dashing : bool = false
@export var ghost_time : float = 0.01
var ghost_timer : float
@export var ghost_node : PackedScene

# Kierunek poruszania się
var dir: float = 0.0

signal taking_damage

var previous_frame : int = 0

var taking_knockback : bool
@export var knockback_multiplier : float = 1.0

@export var default_weapon : int

@export var ability_cooldown : float
var ability_cooldown_timer : float
var using_ability : bool = false

# Wartości prędkości podczas skoku na podstawie równania rzutu pionowego
@onready var jump_speed: float = ((2.0 * jump_height) / jump_peak) * -1
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_peak * jump_peak)) * -1
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_descent * jump_descent)) * -1

# Odniesienia do potrzebnych węzłów
@onready var sprite = get_node("AnimatedSprite2D")
@onready var healthbar = get_node("HUD/healthbar")
@onready var expbar = get_node("HUD/expbar")
@onready var weapons = $AnimatedSprite2D.get_children()
@onready var level = get_tree().get_root().get_child(0)


var selected_weapon : Weapon

var blinking_timer: float = 0
# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Inicjalizuje state machine
	$state_machine.init(self)
	
	$damage_timer.timeout.connect(standard_color)
	if level is Level:
		level.pause.connect(on_paused)
	
	for weapon in weapons:
		if weapon.has_method("set_target"):
			weapon.set_target("enemies")
	switch_weapon(default_weapon)
	
	PlayerVariables.ammo = PlayerVariables.MAX_AMMO
	set_enabled(false)
	hide()
	


# Wywoływane podczas każdej klatki
func _process(delta):
	# Wywołuje pętle state machine
	$state_machine.process(delta)
	
	
	exp_bar_update()
	if PlayerVariables.health <= 0:
		die()
	
	if PlayerVariables.dash_charges == PlayerVariables.MAX_DASH_CHARGES:
		$dash_cooldown.stop()
	elif $dash_cooldown.is_stopped():
		$dash_cooldown.start()
	if PlayerVariables.abilities.dash_charge:
		PlayerVariables.MAX_DASH_CHARGES = 2
	else:
		PlayerVariables.MAX_DASH_CHARGES = 1
	PlayerVariables.dash_charges = min(PlayerVariables.dash_charges, PlayerVariables.MAX_DASH_CHARGES)
	
	clamp(PlayerVariables.ammo, 0, PlayerVariables.MAX_AMMO)
	
	process_weapons()
	process_footstep_audio()
	process_ghosting()
	process_abilities()


# Obsługuje fizykę 
func _physics_process(delta):
	# Wywołuje pętlę fizyczną state machine
	$state_machine.physics(delta)
	
	if taking_knockback and is_on_floor():
		taking_knockback = false


func _input(event):
	if event is InputEventKey and event.keycode in range(49, 58):
		switch_weapon(event.keycode - 49)


# | ============================================================================= |


func process_ghosting():
	if dashing:
		if ghost_timer <= 0:
			var ghost = ghost_node.instantiate()
			ghost.player = self
			ghost.global_position = global_position
			ghost.scale = sprite.scale * scale
			get_tree().current_scene.add_child(ghost)
			ghost_timer = ghost_time
		ghost_timer -= get_process_delta_time()


func process_footstep_audio():
	if ((previous_frame == 1 and sprite.frame == 2) or (previous_frame == 5 and sprite.frame == 6)) and sprite.animation == "walk":
		$footstep.play()
	previous_frame = sprite.frame


# Wyłącza funkcjonalność gracza (fizyka, poruszanie się)
func set_enabled(value : bool):
	set_physics_process(value)
	set_process(value)
	set_process_input(value)
	$Camera2D.enabled = value
	$HUD.visible = value


# Pojawianie się gracza
func spawn(pos):
	position = pos
	PlayerVariables.health = PlayerVariables.MAX_HEALTH
	set_enabled(true)
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
		velocity.x = dir * min(acceleration * accel_modifier + abs(velocity.x), speed * speed_modifier)


# Skok
func jump():
	$state_machine.change_state($state_machine/jump)


func dash():
	if !taking_knockback and PlayerVariables.dash_charges > 0:
		PlayerVariables.dash_charges -= 1
		dashing = true
		#set_collision_mask_value(2, false)
		#set_collision_layer_value(1, false)
		#set_collision_layer_value(3, false)
		
		$dash.play()
		$Camera2D.add_trauma(0.5)
		
		dir = sprite.scale.x / abs(sprite.scale.x)
		velocity.x = dir * speed * 8
		
		await get_tree().create_timer(0.09).timeout
		
		#set_collision_mask_value(2, true)
		#set_collision_layer_value(1, true)
		#set_collision_layer_value(3, true)
		dashing = false


# Wymuszenie chodu gracza (do przerywników)
func walk(direction: String, distance: float):
	if distance > 0:
		var duration : float
		var effective_acceleration : float = acceleration * Engine.physics_ticks_per_second
		var acceleration_duration : float
		var acceleration_distance : float
		
		acceleration_duration = speed / effective_acceleration
		acceleration_distance = (effective_acceleration * pow(acceleration_duration, 2)) / 2
		duration = ((distance - acceleration_distance) / speed) + acceleration_duration
		
		set_direction(direction)
		$state_machine.change_state($state_machine/walk)
		await get_tree().create_timer(duration).timeout
		$state_machine.change_state($state_machine/idle)


# Zadaje obrażenia graczowi
func apply_damage(damage, knockback, pos : Vector2):
	if $damage_timer.is_stopped():
		PlayerVariables.health -= damage
		$damage_timer.start()
		taking_damage.emit()
		apply_knockback(knockback, pos)
		
		invincibility_frames()


# Odrzucenie podczas otrzymywania obrażeń
func apply_knockback(strength, pos : Vector2):
	if strength != 0:
		pos += Vector2(0, 10)
		taking_knockback = true
		var direction = pos.direction_to(global_position)
		velocity = direction.normalized() * strength * knockback_multiplier * speed_modifier


# Ustawienie koloru gracza na standardowy
func standard_color():
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1)
	
	# Włącza kolizję z wrogami
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true)


# Aktualizacja paska i poziomu doświadczenia
func exp_bar_update():
	if PlayerVariables.experience >= PlayerVariables.MAX_EXP:
		PlayerVariables.experience -= PlayerVariables.MAX_EXP
		PlayerVariables.exp_lvl += 1
		PlayerVariables.MAX_EXP *= 1.3
		#Odwołanie do HUD gracza i zmiana wartości liczbowej lvl exp-a
		PlayerVariables.skill_points += 1
	$HUD/level.text = str(PlayerVariables.exp_lvl)


# Śmierć gracza
func die():
	# Pojawia się menu śmierci
	var death_menu = load("res://assets/ui/death_menu/death_menu.tscn").instantiate()
	get_parent().add_child(death_menu)
	
	# Zatrzymuje gracza jeśli chodził lub był w skoku
	$state_machine.change_state($state_machine/idle)
	
	# Zatrzymuje proces gracza
	await $damage_timer.timeout
	set_process(false)
	set_physics_process(false)
	set_process_input(false)


#Funkcja odpowiadająca za mruganie gracza po otrzymaniu obrażeń
func invincibility_frames():
	# Wyłącza kolizję z wrogami
	set_collision_layer_value(4, false)
	set_collision_mask_value(3, false)
	blinking_timer = 0.1 * $damage_timer.wait_time
	
	while not $damage_timer.is_stopped():
		#Zmiana koloru gracza na czerwony(RGB)
		$AnimatedSprite2D.self_modulate.a = 0.5
		selected_weapon.self_modulate.a = 0.5
		
		#Program czeka czas okreslony przez zmienną "blinking_timer"
		await get_tree().create_timer(blinking_timer).timeout
		selected_weapon.self_modulate.a = 1
		blinking_timer -= blinking_timer * 0.1
		await get_tree().create_timer(blinking_timer).timeout


# Update broni
func process_weapons():
	if is_processing_input():
		if selected_weapon and selected_weapon.automatic == false:
			if Input.is_action_just_pressed("attack"):
				selected_weapon.attack()
		elif selected_weapon:
			if Input.is_action_pressed("attack"):
				selected_weapon.attack()


func switch_weapon(weapon : int):
	if weapon <= weapons.size() - 1:
		if selected_weapon:
			selected_weapon.hide()
		selected_weapon = weapons[weapon]
		selected_weapon.show()


func hide_weapons():
	for i in weapons:
		i.hide()


func on_paused(value):
	if value == true:
		sprite.pause()


func move_camera(new_position : Vector2):
	$Camera2D.global_position = new_position


func _on_dash_cooldown_timeout():
	if PlayerVariables.dash_charges < PlayerVariables.MAX_DASH_CHARGES:
		PlayerVariables.dash_charges += 1


func set_player_time_scale(new_scale : float):
	speed_modifier = new_scale
	accel_modifier = new_scale
	sprite.speed_scale = new_scale
	for weapon in weapons:
		weapon.speed_scale = new_scale


func process_abilities():
	
	if Input.is_action_just_pressed("use_ability") and ability_cooldown_timer <= 0 and $HUD.selected_ability and !using_ability:
		match $HUD.selected_ability.name:
			"quake":
				using_ability = true
				
				$HUD/quake_effect.fire()
				var enemies = get_tree().get_nodes_in_group("enemies")
				for enemy in enemies as Array[Enemy]:
					if enemy.position.distance_to(position) <= PlayerVariables.quake_range:
						if (enemy.position.x - position.x) / abs(enemy.position.x - position.x) == sprite.scale.x / abs(sprite.scale.x):
							var strength = randf_range(0.75 * PlayerVariables.quake_strength, 1.25 * PlayerVariables.quake_strength)
							enemy.apply_knockback(strength, position)
				
				ability_cooldown_timer = ability_cooldown
				using_ability = false
			"bullet_time":
				using_ability = true
				
				var time_mod = 0.5
				Engine.time_scale = time_mod
				set_player_time_scale(0.8 / time_mod)
				
				$HUD/bullet_time_effect.enable()
				AudioServer.get_bus_effect(2, 0).pitch_scale = 0.7
				
				await get_tree().create_timer(PlayerVariables.bullet_time_duration).timeout
				
				AudioServer.get_bus_effect(2, 0).pitch_scale = 1.0
				$HUD/bullet_time_effect.disable()
				
				Engine.time_scale = 1
				set_player_time_scale(1)
				
				ability_cooldown_timer = ability_cooldown
				using_ability = false
	
	if ability_cooldown_timer > 0:
		ability_cooldown_timer -= get_process_delta_time()
