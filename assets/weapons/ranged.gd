extends Weapon
class_name Ranged

@export var bullet_type : PackedScene
@export var spread : float
@export var trauma : float
@export var ammo_cost : float

var gunshot_sound : AudioStreamPlayer2D

@onready var camera = get_node("../../Camera2D")


func attack():
	if attack_time <= 0 and PlayerVariables.ammo >= ammo_cost:
		camera.add_trauma(trauma)
		animation = "attack"
		gunshot_sound.play()
		
		var bullet = bullet_type.instantiate()
		bullet.spread = spread
		bullet.direction = sprite.scale.x / abs(sprite.scale.x)
		bullet.global_position = $Marker2D.global_position
		bullet.scale = sprite.scale * 0.5
		
		bullet.damage = damage
		bullet.knockback = knockback
		
		get_tree().get_root().add_child(bullet)
		attack_time = attack_cooldown
		PlayerVariables.ammo -= ammo_cost
