extends Node

@export var enemy_scene: PackedScene

@export var cloudspeed: float = 0.2

@onready var clouds = get_node("ParallaxBackground/clouds_layer/clouds")
@onready var enemyspawn = get_node("enemy_spawnpoint")

# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Dodaje gracza i wroga
	$player.spawn($spawnpoint.position)
	$enemy_spawn_timer.timeout.connect(_spawn_enemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_clouds()


# | ============================================================================= |


func _spawn_enemy():
	spawn_enemy($enemy_spawnpoint.position)


func spawn_enemy(pos):
	# Tworzy nową instancję sceny z wrogiem
	var enemy = enemy_scene.instantiate()
	
	# Ustawia położenie wroga na wybraną
	enemy.position = pos
	
	# Dodaje nowo utworzonego wroga do sceny
	add_child(enemy)


func move_clouds():
	clouds.position.x += cloudspeed
	if clouds.position.x >= 1024:
		clouds.position.x = 0
