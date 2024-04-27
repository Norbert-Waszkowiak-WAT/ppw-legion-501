extends CanvasLayer

var selected_ability : WheelOption
@export var ability_cooldown : float
var cooldown_timer : float


func _ready():
	$radial_ability_menu.hide()


func _process(delta):
	if get_parent().is_processing_input():
		if Input.is_action_just_pressed("ability_menu"):
			$radial_ability_menu.show()
			Engine.time_scale = 0.1
		if Input.is_action_just_released("ability_menu"):
			$radial_ability_menu.hide()
			Engine.time_scale = 1
			selected_ability = $radial_ability_menu.options[$radial_ability_menu.selected_option]
			
		if Input.is_action_just_pressed("use_ability") and cooldown_timer <= 0 and selected_ability != null:
			cooldown_timer = ability_cooldown
	
	if selected_ability and !PlayerVariables.abilities[selected_ability.name]:
		selected_ability = null
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		$selected_ability.self_modulate = Color(0.75, 0.75, 0.75)
	else:
		$selected_ability.self_modulate = Color.WHITE
	
	$selected_ability/ProgressBar.max_value = ability_cooldown
	$selected_ability/ProgressBar.value = cooldown_timer
	$selected_ability.texture = selected_ability
	
