extends Enemy


# | ============================================================================= |


# Wywoływana na początku sceny
func _ready():
	super()

	
	# Ustawia cel broni na gracza
	weapon.set_monitoring(true)


# Wywoływana na każdej klatce
func _process(delta):
	super(delta)


# Obsługuje fizykę
func _physics_process(delta):
	super(delta)


# | ============================================================================= |
