extends Node
class_name Level


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	# Dodaje gracza
	if $player and $player_spawnpoint:
		$player.spawn($player_spawnpoint.position)
	elif !$player:
		print("No player found in level scene.")
	else:
		print("No player spawnpoints found.")
	
	# Dodaje wroga
	if $spawnpoints:
		for i in $spawnpoints.get_children():
			spawn_enemy(i.enemy_type, i.position)
	else:
		print("No enemy spawnpoints node found.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# | ============================================================================= |


func spawn_enemy(enemy_type : PackedScene, pos : Vector2):
	var enemy
	
	# Tworzy nową instancję sceny z wrogiem
	enemy = enemy_type.instantiate()
	
	# Ustawia położenie wroga na wybraną
	enemy.position = pos
	
	# Dodaje nowo utworzonego wroga do sceny
	add_child(enemy)
