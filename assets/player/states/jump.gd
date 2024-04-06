extends State

# Odniesienia do pozostałych stanów
@export var idle: State
@export var walk: State
@export var fall: State


# Wywoływana gdy gracz wchodzi w stan
func enter():
	player.sprite.play("jump")
	player.velocity.y = player.jump_speed
	if not player.taking_knockback:
		player.get_node("jump").play()


# Wywoływana na każdej klatce
func process(_delta: float) -> State:
	if player.is_processing_input():
		if Input.is_action_pressed("move_right"):
			player.set_direction("right")
		elif Input.is_action_pressed("move_left"):
			player.set_direction("left")
		else:
			player.set_direction("0")
		# Double jump
		if Input.is_action_just_pressed("jump") and PlayerVariables.abilities.double_jump and not PlayerVariables.double_jumped:
			PlayerVariables.double_jumped = true
			return self
		
		if Input.is_action_just_pressed("dash") and PlayerVariables.abilities.air_dash:
			player.dash()
	return null


# Wywoływana na każdej klatce, odpowiada za procesy fizyczne
func physics(delta) -> State:
	if !player.dashing:
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
