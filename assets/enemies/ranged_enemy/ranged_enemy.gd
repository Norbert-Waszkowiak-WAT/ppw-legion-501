extends Enemy

@onready var ray = $AnimatedSprite2D/enemy_blaster/aiming_ray

# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	attack_range = weapon.weapon_range
	super()


# Wywoływana na każdej klatce
func _process(delta):
	super(delta)


# Obsługuje fizykę
func _physics_process(delta):
	super(delta)


# | ============================================================================= |


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
		speed = chase_speed
		update_path()
		change_state(states.chase)
	if ray.is_colliding() and sees_player() and is_on_floor():
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczas gonienia gracza
func chase(delta: float):
	if reaction_timer <= 0:
		pass
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
		
	if ray.is_colliding() and is_on_floor():
		change_state(states.attack)


# Odpowiada za zachowanie wroga podczes ataku
func attack(delta: float):
	speed = 0
	if reaction_timer <= 0:
		turn_towards_player()
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
	if !ray.is_colliding():
		change_state(states.chase)
