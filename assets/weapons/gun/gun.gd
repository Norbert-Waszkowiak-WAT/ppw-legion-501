extends Ranged


@export var gunshot_light : AudioStreamPlayer2D
@export var gunshot_standard : AudioStreamPlayer2D
@export var gunshot_heavy : AudioStreamPlayer2D


func _ready():
	super()
	if user is Enemy:
		gunshot_sound = $gunshot_sound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	
	if !attacking:
		animation = sprite.animation
		frame = sprite.frame
		frame_progress = sprite.frame_progress
	if !is_playing():
		play()
	
	if user is Player:
		if PlayerVariables.abilities["heavy_hitter"] == true:
			automatic = false
			if PlayerVariables.abilities.tuned_trigger:
				fire_rate = 300
			else:
				fire_rate = 200
			if PlayerVariables.abilities.large_caliber:
				damage = 30
			else:
				damage = 20
			spread = 0.3
			knockback = 15
			trauma = 0.4
			ammo_cost = 3
			gunshot_sound = gunshot_heavy
		elif PlayerVariables.abilities["high_speed_low_drag"] == true:
			automatic = true
			fire_rate = 950
			if PlayerVariables.abilities.hollow_points:
				damage = 9
			else:
				damage = 6
			spread = 1.3
			if PlayerVariables.abilities.hollow_points_2:
				knockback = 0.1
			else:
				knockback = 0
			trauma = 0.3
			ammo_cost = 0.75
			gunshot_sound = gunshot_light
		else:
			automatic = true
			fire_rate = 500
			if PlayerVariables.abilities.stopping_power:
				damage = 15
			else:
				damage = 10
			spread = 0.8
			if PlayerVariables.abilities.stopping_power_2:
				knockback = 0.1
			else:
				knockback = 0
			trauma = 0.35
			ammo_cost = 0.5
			gunshot_sound = gunshot_standard



