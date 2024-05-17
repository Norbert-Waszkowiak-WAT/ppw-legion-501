extends Level


enum Sequence {ENTER_SEQ, HORDE_SEQ, ATTACK_SEQ}
var current_sequence : Sequence

@export var enemy_spawn_chance : float
@export var waves_in_sequence : float
var waves_remaining : float

@export var boss_damage_to_shield : float
var boss_health_to_shield : float

@onready var player : Player = $player
@onready var terrain : TileMap = $terrain
@onready var boss : Boss = $boss


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	#PlayerVariables.skill_points = 10
	
	enter_sequence()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	
	match current_sequence:
		Sequence.HORDE_SEQ:
			var enemies = get_tree().get_nodes_in_group("enemies")
			if enemies.size() == 0:
				if waves_remaining > 0:
					spawn_wave_of_enemies()
					waves_remaining -= 1
				else:
					attack_sequence()
			for enemy in enemies as Array[Enemy]:
				if enemy.current_state == Enemy.states.idle:
					enemy.change_state(Enemy.states.chase)
		Sequence.ATTACK_SEQ:
			if boss.health <= boss_health_to_shield:
				horde_sequence()



# | ============================================================================= |


func enter_sequence():
	change_sequence(Sequence.ENTER_SEQ)
	player.set_process_input(false)
	player.walk("right", 200)
	
	await get_tree().create_timer(3.0).timeout
	
	player.set_zoom(Vector2(3, 3))
	player.move_camera(Vector2(36, -160))
	
	await get_tree().create_timer(1.5).timeout
	
	terrain.set_cell(0, Vector2i(-16, 0), 5, Vector2i(5, 2))
	terrain.set_cell(0, Vector2i(-16, -1), 5, Vector2i(5, 1))
	terrain.set_cell(0, Vector2i(-16, -2), 5, Vector2i(5, 1))
	terrain.set_cell(0, Vector2i(-16, -3), 5, Vector2i(5, 1))
	terrain.set_cell(0, Vector2i(-16, -4), 5, Vector2i(5, 2), 3)
	player.set_zoom(Vector2(4.5, 4.5))
	player.reset_camera()
	player.get_node("Camera2D").position.y = -63
	player.set_process_input(true)
	
	horde_sequence()


func horde_sequence():
	change_sequence(Sequence.ENTER_SEQ)
	boss.shield_active = true
	# Może leczenie bossa
	if player.position.y < -150:
		player.apply_knockback(200, Vector2(35, -165))
	
	await get_tree().create_timer(1.0).timeout
	waves_remaining = waves_in_sequence
	change_sequence(Sequence.HORDE_SEQ)
	boss.change_sequence(Boss.Sequence.HORDE_SEQ)
	reset_boosters()


func attack_sequence():
	change_sequence(Sequence.ATTACK_SEQ)
	boss.change_sequence(Boss.Sequence.ATTACK_SEQ)
	if player.position.y < -125:
		player.apply_knockback(200, Vector2(35, -120))
	boss.shield_active = false
	boss_health_to_shield = boss.health - boss_damage_to_shield
	# Boss zaczyna strzelać pociskami


func change_sequence(new_seq : Sequence):
	current_sequence = new_seq


func reset_boosters():
	var boosters = get_tree().get_nodes_in_group("health_boosters")
	for booster in boosters:
		if booster.has_method("reset"):
			booster.reset()


func spawn_wave_of_enemies():
	randomize()
	for i in $spawnpoints.get_children():
		if randf() <= enemy_spawn_chance:
			spawn_enemy(i.enemy_type, i.position)

func spawn_enemies():
	pass
