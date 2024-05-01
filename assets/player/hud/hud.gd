extends CanvasLayer

var selected_ability : WheelOption

@onready var player = get_parent()
var previous_time_scale : float


func _ready():
	$radial_ability_menu.hide()


func _process(delta):
	if player.is_processing_input():
		if Input.is_action_just_pressed("ability_menu"):
			$radial_ability_menu.show()
			previous_time_scale = Engine.time_scale
			Engine.time_scale = 0.1
		if Input.is_action_just_released("ability_menu"):
			$radial_ability_menu.hide()
			Engine.time_scale = previous_time_scale
			selected_ability = $radial_ability_menu.options[$radial_ability_menu.selected_option]
			
		
	
	if selected_ability and !PlayerVariables.abilities[selected_ability.name]:
		selected_ability = null
	
	if player.ability_cooldown_timer > 0:
		$selected_ability.self_modulate = Color(0.75, 0.75, 0.75)
	else:
		$selected_ability.self_modulate = Color.WHITE
	
	$selected_ability/ProgressBar.max_value = player.ability_cooldown
	$selected_ability/ProgressBar.value = player.ability_cooldown_timer
	$selected_ability.texture = selected_ability
	
