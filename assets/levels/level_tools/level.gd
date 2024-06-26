extends Node
class_name Level


signal pause(value : bool)

@export var next_level : String


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.set_time_scale(1)
	# Konfiguruje warunek wygranej
	for i in $winning_areas.get_children():
		i.level_completed.connect(on_level_completed)
	
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
		
	$player/HUD/tint.color.a = 1.0
	var tween = create_tween()
	tween.tween_property($player/HUD/tint, "color:a", 0.0, 1.3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_paused()


# | ============================================================================= |


func spawn_enemy(enemy_type : PackedScene, pos : Vector2):
	var enemy
	
	# Tworzy nową instancję sceny z wrogiem
	enemy = enemy_type.instantiate()
	
	# Ustawia położenie wroga na wybraną
	enemy.position = pos
	
	# Dodaje nowo utworzonego wroga do sceny
	add_child(enemy)


func set_paused(value : bool):
	pause.emit(value)
	value = !value
	for i in find_children("*"):
		i.set_process(value)
		i.set_physics_process(value)
		i.set_process_input(value)
		if i is AnimatedSprite2D:
			if value == true:
				i.pause()
			else:
				i.play()
	set_process(value)
	set_physics_process(value)
	set_process_input(value)


func check_paused():
	if Input.is_action_just_pressed("escape"):
		set_paused(true)
		var escape_menu = load("res://assets/ui/esc_menu/esc_menu.tscn").instantiate()
		add_child(escape_menu)
	if Input.is_action_just_pressed("skill_tree"):
		set_paused(true)
		var skill_tree = load("res://assets/ui/skill_tree/skill_tree_menu.tscn").instantiate()
		add_child(skill_tree)


func on_level_completed():
	var winning_menu = load("res://assets/ui/winning_menu/winning_menu.tscn").instantiate()
	winning_menu.next_level = next_level
	add_child(winning_menu)
