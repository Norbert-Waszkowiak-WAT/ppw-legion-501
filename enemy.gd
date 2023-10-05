extends CharacterBody2D

signal hit(damage)

@export var speed = 25.0
const GRAVITY = 200.0
var dir = 0.0

# | ============================================================================= |

func _ready():
	var dir_timer = get_node("dir_timer")
	#Dodanie timera
	dir_timer.start()
	
	dir_timer.timeout.connect(get_dir)
	#timer wysyła sygnał o zakończeniu liczenia, przez co aktywuje get_dir()
	
	# | ============================================================================= |
	
func _physics_process(delta):
	velocity.y += delta * GRAVITY
	# Dodanie grawitacji
	
	velocity.x = dir * speed
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider_name() == "player":
			hit.emit(1)
	
	
	
	# Obsługuje poruszanie i kolizję
	move_and_slide()

# | ============================================================================= |

func get_dir():
	var chance = randf()
	#Losuje float w zakresie od 0 do 1
	if chance < 0.3:
		dir = 1.0
		scale.x = scale.y * 1
	elif chance < 0.6:
		dir = -1.0
		scale.x = scale.y * -1
	else:
		dir = 0
	
# | ============================================================================= |
