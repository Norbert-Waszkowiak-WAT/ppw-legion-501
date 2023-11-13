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
	
	$healthbar.hide()
	$health_timer.timeout.connect(hide_health)
	
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


func change_state(state : states):
	await get_tree().create_timer(reaction_time).timeout
	current_state = state

# Odpowiada za zachowanie wroga poza walką
func idle():
	if position.distance_to(player.position) <= detection_range:
		$dir_timer.stop()
		change_state(states.chase)
	if position.distance_to(player.position) <= attack_range:
		$dir_timer.stop()
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczas gonienia gracza
func chase():
	if position.direction_to(player.position).x > 0:
		dir = 1
	else:
		dir = -1
	sprite.scale.x = sprite.scale.y * dir
	
	if position.distance_to(player.position) > detection_range:
		$dir_timer.start()
		change_state(states.idle)
	if position.distance_to(player.position) <= attack_range:
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczes ataku
func attack():
	dir = 0
	weapon.attack(position)
	
	if position.distance_to(player.position) > detection_range:
		$dir_timer.start()
		change_state(states.idle)
	if position.distance_to(player.position) <= detection_range:
		change_state(states.chase)


# Ukrywa pasek życia po określonym czasie
func hide_health():
	$healthbar.hide()
	$health_timer.stop()


# Śmierć wroga
func die():
	sprite.self_modulate = Color(1.0, 0, 0, 1)
	set_collision_layer_value(3, false)
	await get_tree().create_timer(death_time).timeout
	queue_free()


# | ============================================================================= |

