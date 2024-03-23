extends Level


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	$player.apply_damage(PlayerVariables.health / 2, 0, Vector2.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)


# | ============================================================================= |
