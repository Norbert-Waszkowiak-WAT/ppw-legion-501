extends State

# Odniesienia do pozostałych stanów
@export var idle: State
@export var walk: State
@export var fall: State


# Wywoływana gdy gracz wchodzi w stan
func enter():
	player.jump()


# Wywoływana na każdej klatce
func process(delta: float) -> State:
	if player.is_processing_input():
		if Input.is_action_pressed("move_right"):
			player.set_direction("right")
		elif Input.is_action_pressed("move_left"):
			player.set_direction("left")
		else:
			player.set_direction("0")
	return null


# Wywoływana na każdej klatce, odpowiada za procesy fizyczne
func physics(delta) -> State:
	player.horizontal_movement()
	player.velocity.y += player.get_gravity() * delta
	player.move_and_slide()
	
	if player.velocity.y > 0:
		return fall
	if player.is_on_floor() and player.dir == 0:
		return idle
	elif player.is_on_floor():
		return walk
	
	return null
