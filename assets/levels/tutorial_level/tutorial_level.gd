extends Level


var current_tutorial_page : int = 0


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	$player.apply_damage(PlayerVariables.health / 2, 0, Vector2.ZERO)
	
	await get_tree().create_timer(1).timeout
	$tutorial.show_tutorial(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	match current_tutorial_page:
		0:
			if $player.velocity.x != 0:
				$tutorial.hide_tutorial()
				current_tutorial_page += 1
		1:
			if not $tutorial.visible:
				$tutorial.show_tutorial(current_tutorial_page)
			if PlayerVariables.health == PlayerVariables.MAX_HEALTH:
				$tutorial.hide_tutorial()
				current_tutorial_page += 1
		2:
			if $player.global_position.x >= 180 and not $tutorial.visible:
				$tutorial.show_tutorial(current_tutorial_page)
			if $player.position.y <= -10:
				$tutorial.hide_tutorial()
				current_tutorial_page += 1
		3:
			if $player.global_position.y <= -125 and $player.global_position.x >= 450 and not $tutorial.visible:
				$tutorial.show_tutorial(current_tutorial_page)
			if Input.is_action_just_pressed("attack"):
				$tutorial.hide_tutorial()
				current_tutorial_page += 1
		


# | ============================================================================= |
