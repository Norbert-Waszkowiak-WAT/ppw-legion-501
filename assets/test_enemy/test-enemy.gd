extends Enemy


enum states {idle, chase, attack}
var current_state : states
var starting_state : states = states.idle


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	change_state(starting_state)
	super()
	
	$dir_timer.timeout.connect(get_dir)
	$dir_timer.start()
	
	# Ustawia cel broni na gracza
	weapon.set_monitoring(true)


# Wywoływana na każdej klatce
func _process(delta):
	super(delta)


# Obsługuje fizykę
func _physics_process(delta):
	match current_state:
		states.idle:
			idle()
		states.chase:
			chase()
		states.attack:
			attack()
	check_movement()
	super(delta)


# | ============================================================================= |


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
	await get_tree().create_timer(reaction_time).timeout
	current_state = state


# Odpowiada za zachowanie wroga poza walką
func idle():
	if position.distance_to(player.position) <= detection_range and sees_player():
		speed = chase_speed
		$dir_timer.stop()
		change_state(states.chase)
	if position.distance_to(player.position) <= attack_range and sees_player():
		$dir_timer.stop()
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczas gonienia gracza
func chase():
	if position.direction_to(player.position).x == 0:
		dir = 0
	elif position.direction_to(player.position).x > 0:
		dir = 1
	else:
		dir = -1
	sprite.scale.x = sprite.scale.y * dir
	
	if position.distance_to(player.position) > detection_range or !sees_player():
		await get_tree().create_timer(memory_time).timeout
		speed = idle_speed
		$dir_timer.start()
		change_state(states.idle)
	if position.distance_to(player.position) <= attack_range:
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczes ataku
func attack():
	dir = 0
	weapon.attack()
	
	if position.distance_to(player.position) > detection_range or !sees_player():
		await get_tree().create_timer(memory_time).timeout
		speed = idle_speed
		$dir_timer.start()
		change_state(states.idle)
	if position.distance_to(player.position) <= detection_range:
		speed = chase_speed
		change_state(states.chase)


func check_movement():
	match current_state:
		states.chase:
			if !$left_long.get_collider() or !$right_long.get_collider():
				jump()
			if $left_step_angle.get_collider() and !$left_wall.get_collider() and dir == -1:
				jump()
			elif !$left_short.get_collider() and dir == -1 and !$left_wall.get_collider() and player.position.y < position.y and !$left_step_down.get_collider():
				jump()
			if $right_step_angle.get_collider() and !$right_wall.get_collider() and dir == 1:
				jump()
			elif !$right_short.get_collider() and dir == 1 and !$right_wall.get_collider() and player.position.y < position.y and !$right_step_down.get_collider():
				jump()
		states.idle:
			if !$left_short.get_collider() and dir == -1 and is_on_floor():
				dir = 0
			if !$right_short.get_collider() and dir == 1 and is_on_floor():
				dir = 0


# | ============================================================================= |

