extends Weapon

@export var bullet_type : PackedScene

@onready var sprite = get_parent()
@onready var gun_sprite = get_node("AnimatedSprite2D")
@onready var camera = get_node("../../Camera2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	gun_sprite.animation = sprite.animation
	gun_sprite.frame = sprite.frame
	gun_sprite.frame_progress = sprite.frame_progress


func attack():
	if $attack_timer.is_stopped():
		#camera.add_trauma(0.2)
		gun_sprite.animation = "attack"
		$AudioStreamPlayer2D.play()
		
		var bullet = bullet_type.instantiate()
		bullet.direction = sprite.scale.x / abs(sprite.scale.x)
		bullet.global_position = $Marker2D.global_position
		bullet.scale = sprite.scale * 0.5
		
		bullet.damage = damage
		bullet.knockback = knockback
		
		get_tree().get_root().add_child(bullet)
		$attack_timer.start()
