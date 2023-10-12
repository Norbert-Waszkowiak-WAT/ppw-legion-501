extends Node

@export var enemy_scene : PackedScene


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Dodaje gracza i wroga
	$player.spawn($spawnpoint.position)
	spawn_enemy($enemy_spawnpoint.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# | ============================================================================= |


func spawn_enemy(pos):
	# Tworzy nową instancję sceny z wrogiem
	var enemy = enemy_scene.instantiate()
	
	# Ustawia położenie wroga na wybraną
	enemy.position = pos
	
	# Dodaje nowo utworzonego wroga do sceny
	add_child(enemy)
