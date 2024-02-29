extends TextureProgressBar


var damage_time : float = 1

var tween

@onready var user = get_node("../../")


# Called when the node enters the scene tree for the first time.
func _ready():
	$damagebar.value = PlayerVariables.health
	user.taking_damage.connect(update_bar)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if PlayerVariables.health > $damagebar.value:
		$damagebar.value = PlayerVariables.health


# Rozpoczyna nową animację i kończy poprzednią, jeśli istniała
func animate():
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)


# Odtwarza animację paska
func update_bar():
	animate()
	tween.tween_interval(damage_time)
	tween.tween_property($damagebar, "value", PlayerVariables.health, 0.2)

