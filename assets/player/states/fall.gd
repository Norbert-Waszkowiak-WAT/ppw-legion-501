extends State

# Odniesienia do pozostałych stanów
@export var idle: State
@export var walk: State
@export var jump: State


# Wywoływana gdy gracz wchodzi w stan
func enter():
	player.sprite.play("fall")


# Wywoływana na każdej klatce
func process(_delta: float) -> State:
	if player.is_processing_input():
		if Input.is_action_just_pressed("jump"):
			# Double jump
			if PlayerVariables.abilities.double_jump and not PlayerVariables.double_jumped:
				PlayerVariables.double_jumped = true
				return jump
			# Kolejkowanie skoku
			elif not player.is_on_floor():
				player.queued_jump = true
		
		
		if Input.is_action_pressed("move_right"):
			player.set_direction("right")
		elif Input.is_action_pressed("move_left"):
			player.set_direction("left")
		else:
			player.set_direction("0")
		
		if Input.is_action_just_pressed("dash") and PlayerVariables.abilities.air_dash:
			player.dash()
	return null


# Wywoływana na każdej klatce, odpowiada za procesy fizyczne
func physics(delta: float) -> State:
	player.velocity.y += player.get_gravity() * delta * player.speed_modifier
	
	player.move_and_slide()
	
	if !player.dashing:
		player.horizontal_movement()
	
	if player.velocity.y < 0:
		return jump
	if player.is_on_floor() and player.dir == 0:
		player.get_node("land").play()
		return idle
	elif player.is_on_floor():
		player.get_node("land").play()
		return walk
	
	return null
