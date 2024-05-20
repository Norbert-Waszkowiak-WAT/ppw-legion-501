extends RayCast2D


var camera

@export var laser_width : float
var laser_enabled : bool = false:
	set(value):
		laser_enabled = value
		set_laser_visible(value)
		set_physics_process(value)
		$start_particles.emitting = value
		$impact_particles.emitting = value
		$beam_particles.emitting = value

@export var damage_per_second : float

var target_point : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	set("laser_enabled", false)
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO

#func _input(event):
	#if event is InputEventMouseButton:
		#set("laser_enabled", event.pressed)


func _physics_process(delta):
	if laser_enabled:
		target_point = to_global(target_position)
		force_raycast_update()
		if is_colliding():
			var collider = get_collider()
			if collider is Enemy or collider is Boss:
				collider.apply_damage(damage_per_second * delta, 0, position)
				if collider is Enemy:
					collider.speed *= 0.5
			target_point = get_collision_point()
		
		var beam_length = to_local(target_point).x
		
		$impact_particles.position = to_local(target_point)
		
		var beam_material : ParticleProcessMaterial = $beam_particles.process_material
		$beam_particles.position.x = beam_length / 2
		beam_material.emission_box_extents = Vector3(beam_length / 2, laser_width / 2, 1)
		
		$Line2D.points[1] = to_local(target_point)


func set_laser_visible(value : bool):
	var target_width
	if value:
		target_width = laser_width
	else:
		target_width = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property($Line2D, "width", target_width, 0.25)
