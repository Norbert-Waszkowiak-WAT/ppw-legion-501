extends Ranged


@export var gunshot_light : AudioStreamPlayer2D
@export var gunshot_standard : AudioStreamPlayer2D
@export var gunshot_heavy : AudioStreamPlayer2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	
	animation = sprite.animation
	frame = sprite.frame
	frame_progress = sprite.frame_progress
	
	if attack_time > 0:
		attack_time -= delta
	
	if PlayerVariables.abilities["heavy_hitter"] == true:
		automatic = false
		fire_rate = 200
		damage = 20
		spread = 0.3
		knockback = 15
		trauma = 0.4
		ammo_cost = 3
		gunshot_sound = gunshot_heavy
	elif PlayerVariables.abilities["high_speed_low_drag"] == true:
		automatic = true
		fire_rate = 950
		damage = 5
		spread = 1.3
		knockback = 0
		trauma = 0.3
		ammo_cost = 1
		gunshot_sound = gunshot_light
	else:
		automatic = true
		fire_rate = 500
		damage = 8
		spread = 0.8
		knockback = 1
		trauma = 0.35
		ammo_cost = 0.5
		gunshot_sound = gunshot_standard



