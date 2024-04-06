extends TextureProgressBar


var damage_time : float = 1
var healing_time : float = 0.4

var damage_tween : Tween
var healing_tween : Tween

@onready var user = get_node("../../")


# Called when the node enters the scene tree for the first time.
func _ready():
	value = PlayerVariables.health
	$damagebar.value = PlayerVariables.health
	user.taking_damage.connect(update_bar)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$healing_bar.value = PlayerVariables.health
	
	if PlayerVariables.health < value:
		value = PlayerVariables.health
	if PlayerVariables.health > $damagebar.value:
		$damagebar.value = PlayerVariables.health
	if $healing_bar.value > value:
		if not healing_tween:
			process_healing_bar()
		elif not healing_tween.is_running():
			process_healing_bar()


func process_healing_bar():
	if healing_tween:
		healing_tween.kill()
	healing_tween = create_tween()
	healing_tween.tween_interval(healing_time)
	healing_tween.tween_property(self, "value", PlayerVariables.health, 0.2)


# Odtwarza animację paska
func update_bar():
	if damage_tween:
		damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.tween_interval(damage_time)
	damage_tween.tween_property($damagebar, "value", PlayerVariables.health, 0.2)

