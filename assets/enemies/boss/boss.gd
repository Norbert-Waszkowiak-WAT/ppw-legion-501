extends StaticBody2D
class_name Boss


signal boss_defeated

enum Sequence {HORDE_SEQ, ATTACK_SEQ}
var current_sequence : Sequence


var shield_active : bool = false
var health : float
const MAX_HEALTH := 2500.0

@export var projectile : PackedScene
@export var projectile_speed : float
@export var projectile_cooldown : float
@export var projectile_randomness : float
var projectile_timer : float = 0

@onready var player = get_parent().get_node("player")


# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH
	$CanvasLayer/healthbar.max_value = MAX_HEALTH


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_sequence:
		Sequence.HORDE_SEQ:
			horde_seq_process(delta)
		Sequence.ATTACK_SEQ:
			attack_seq_process(delta)
	
	if shield_active:
		$CanvasLayer/shield.show()
	else:
		$CanvasLayer/shield.hide()
		
	update_health()
	if health <= 0:
		die()


func apply_damage(damage : float, _knockback, _pos):
	if !shield_active:
		health -= damage
	else:
		player.apply_knockback(200, Vector2(35, -165))


func change_sequence(new_seq : Sequence):
	current_sequence = new_seq
	if new_seq == Sequence.ATTACK_SEQ:
		pass
	elif new_seq == Sequence.HORDE_SEQ:
		pass


func horde_seq_process(delta):
	pass


func attack_seq_process(delta):
	if projectile_timer <= 0 and player.position.y > -150:
		shoot()
		projectile_timer = projectile_cooldown
	projectile_timer -= delta
	


func die():
	set_process(false)
	boss_defeated.emit()


func update_health():
	$CanvasLayer/healthbar.value = health


func shoot():
	var new_projectile = projectile.instantiate()
	var direction = position.direction_to(player.position)
	var randomness = Vector2((randf() - 0.5) * projectile_randomness, (randf() - 0.5) * projectile_randomness)
	new_projectile.position = position
	direction += randomness
	new_projectile.velocity = direction.normalized() * projectile_speed
	
	$projectile_sound.play()
	get_tree().get_root().get_child(1).add_child(new_projectile)
