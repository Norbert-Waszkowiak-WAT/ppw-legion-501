extends State

# Odniesienia do pozostałych stanów
@export var walk: State
@export var jump: State
@export var fall: State


# Wywoływana gdy gracz wchodzi w stan
func enter():
	player.sprite.animation = "idle"
	player.dir = 0
	PlayerVariables.double_jumped = false


# Wywoływana na każdej klatce
func process(_delta: float) -> State:
	if !player.sprite.is_playing():
		player.sprite.play()
	if player.is_processing_input():
		if Input.is_action_just_pressed("jump") and player.is_on_floor():
			return jump
		# Kolejkowanie skoku
		if player.queued_jump and player.is_on_floor():
			player.queued_jump = false
			return jump
		
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			return walk
	return null


# Wywoływana na każdej klatce, odpowiada za procesy fizyczne
func physics(delta: float) -> State:
	player.horizontal_movement()
	player.velocity.y += player.get_gravity() * delta
	player.move_and_slide()
	
	if not player.is_on_floor():
		return fall
	
	return null
