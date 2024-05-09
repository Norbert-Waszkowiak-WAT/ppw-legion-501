extends Weapon
class_name Ranged

@export var bullet_type : PackedScene
@export var spread : float
@export var trauma : float
@export var ammo_cost : float
@export var weapon_range : float

var gunshot_sound : AudioStreamPlayer2D

var attacking : bool = false

var camera

func _ready():
	if user is Player:
		camera = get_node("../../Camera2D")


func _process(delta):
	super(delta)
	if attack_time > 0:
		attack_time -= delta

func attack():
	if user is Player:
		if attack_time <= 0 and PlayerVariables.ammo >= ammo_cost:
			attacking = true
			camera.add_trauma(trauma)
			animation = "attack"
			gunshot_sound.play()
			
			$Marker2D/GPUParticles2D.emitting = true
			
			var bullet = bullet_type.instantiate()
			bullet.bullet_range = weapon_range
			bullet.spread = spread
			bullet.direction = sprite.scale.x / abs(sprite.scale.x)
			bullet.global_position = $Marker2D.global_position
			bullet.scale = sprite.scale * 0.5
			
			bullet.damage = damage
			bullet.knockback = knockback
			
			get_tree().get_root().add_child(bullet)
			attack_time = attack_cooldown
			PlayerVariables.ammo -= ammo_cost
			
			await animation_finished
			
			attacking = false
	elif attack_time <= 0:
		attacking = true
		animation = "attack"
		gunshot_sound.play()
		
		$Marker2D/GPUParticles2D.emitting = true
		
		var bullet = bullet_type.instantiate()
		bullet.bullet_range = weapon_range
		bullet.spread = spread
		bullet.direction = sprite.scale.x / abs(sprite.scale.x)
		bullet.global_position = $Marker2D.global_position
		bullet.scale = sprite.scale * 0.5
		
		bullet.damage = damage
		bullet.knockback = knockback
		
		get_tree().get_root().add_child(bullet)
		attack_time = attack_cooldown
		
		await animation_finished
		
		attacking = false
