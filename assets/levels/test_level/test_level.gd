extends Level


# Prędkość poruszania się chmur
@export var cloudspeed: float = 0.2

@onready var clouds = get_node("ParallaxBackground/clouds_layer/clouds")


# | ============================================================================= |


# Called when the node enters the scene tree for the first time.
func _ready():
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)

# | ============================================================================= |


