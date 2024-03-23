extends Weapon

@export var bullet_type : PackedScene
var spread : float

@export var gunshot_light : AudioStreamPlayer2D
@export var gunshot_standard : AudioStreamPlayer2D
@export var gunshot_heavy : AudioStreamPlayer2D
var gunshot_sound : AudioStreamPlayer2D

@onready var sprite = get_parent()
@onready var gun_sprite = get_node("AnimatedSprite2D")
@onready var camera = get_node("../../Camera2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	
	gun_sprite.animation = sprite.animation
	gun_sprite.frame = sprite.frame
	gun_sprite.frame_progress = sprite.frame_progress
	
	if attack_time > 0:
		attack_time -= delta
	
	if PlayerVariables.abilities["heavy_hitter"] == true:
		automatic = false
		fire_rate = 150
		damage = 20
		spread = 0.1
		gunshot_sound = gunshot_heavy
	elif PlayerVariables.abilities["high_speed_low_drag"] == true:
		automatic = true
		fire_rate = 950
		damage = 2
		spread = 1
		gunshot_sound = gunshot_light
	else:
		automatic = true
		fire_rate = 400
		damage = 10
		spread = 0.5
		gunshot_sound = gunshot_standard


func attack():
	if attack_time <= 0:
		#camera.add_trauma(0.2)
		gun_sprite.animation = "attack"
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
