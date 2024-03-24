extends CharacterBody2D

@export var speed_of_bullet: float = 100
var damage : float
var knockback : float
var direction : float
var spread : float
@export var range : float
var lifetime : float
var life_timer : float = 0.0

@onready var sprite = get_node("Sprite2D")

var emitting : bool = false


func _ready():
	lifetime = range / speed_of_bullet


func _physics_process(_delta):
	for target in $Area2D.get_overlapping_bodies():
		set_physics_process(false)
		if target is Enemy:
			target.apply_damage(damage, knockback, global_position + Vector2(0, 30))
		sprite.hide()
		$GPUParticles2D.emitting = true
		emitting = true
	
	velocity.x = speed_of_bullet * direction
	velocity.y = ((randf() - 0.5) / 5) * spread * speed_of_bullet
	
	move_and_slide()


func _process(delta):
	life_timer += delta
	
	if life_timer >= lifetime:
		queue_free()
	
	if emitting == true and $GPUParticles2D.emitting == false:
		queue_free()
