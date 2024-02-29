extends State

# Odniesienia do pozostałych stanów
@export var idle: State
@export var jump: State
@export var fall: State

@onready var sprite = get_node("../../AnimatedSprite2D")


# Wywoływana gdy gracz wchodzi w stan
func enter():
	player.sprite.animation = "walk"


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
		
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
			return idle
		if Input.is_action_pressed("move_right"):
			player.set_direction("right")
		elif Input.is_action_pressed("move_left"):
			player.set_direction("left")
		else:
			player.set_direction("0")
	
	return null


# Wywoływana na każdej klatce, odpowiada za procesy fizyczne
func physics(delta: float) -> State:
	# Nadanie prędkości poziomej i grawitacji
	player.horizontal_movement()
	player.velocity.y += player.get_gravity() * delta
	
	# Obsługuje fizykę gracza
	player.move_and_slide()
	
	if not player.is_on_floor():
		return fall
	
	return null


# Wywoływana gdy gracz wychodzi ze stanu
func exit():
	player.sprite.stop()
