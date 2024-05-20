extends TextureButton


# Odniesienie do poprzedniej umiejętności
@export var previous_button : Node
# Wykluczające się umiejętności
@export var excluded_buttons : Array[Node]
var excluded : bool = false
# Nazwa umiejętności (musi się zgadzać z player_variables.gd)
@export var ability_name : String
# Opis umiejętności
@export_multiline var description : String


@onready var line = $Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Jeśli gracz posiada już tą umiejętność, zaznaczyć to w drzewku
	if ability_name and PlayerVariables.abilities[ability_name]:
		set_pressed_no_signal(true)
	# Ustawienie tekstu przy hoverze nad umiejętnością
	tooltip_text = "[b]" + ability_name.capitalize() + "[/b] \n" + description


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Czyści wszystkie punkty linii
	line.clear_points()
	if previous_button:
		# Rysuje linię między tą a poprzednią umiejętnością
		line.add_point(global_position + size/2)
		line.add_point(previous_button.global_position + size/2)
		# Blokuje umiejętność jeśli poprzednia nie jest odblokowana
		if (PlayerVariables.skill_points > 0 or button_pressed) and (previous_button and previous_button.button_pressed) and !excluded:
			disabled = false
		else:
			disabled = true
	elif excluded:
		disabled = true
	else:
		disabled = false
	
	excluded = false
	for excluded_button in excluded_buttons:
		if excluded_button.button_pressed:
			excluded = true
	
	# Wizualne efekty przycisku (tymczasowe)
	if disabled:
		# Zablokowana
		#material.set_shader_parameter("enabled", true)
		button_pressed = false
		self_modulate = Color(0.2, 0.2, 0.2)
		line.self_modulate = Color(0.2, 0.2, 0.2)
	elif button_pressed:
		# Odblokowana
		#material.set_shader_parameter("enabled", false)
		self_modulate = Color(1.2, 1.2, 1.2)
		line.self_modulate = Color(1, 1, 1)
	else:
		# Możliwa do kupienia
		#material.set_shader_parameter("enabled", true)
		self_modulate = Color(0.7, 0.7, 0.7)
		line.self_modulate = Color(0.5, 0.5, 0.5)
	if is_hovered() and !disabled:
		# Najechana myszką
		self_modulate = Color(1.4, 1.4, 1.4)
	
	# Wyłącza możliwość odblokowania umiejętności, jeśli gracza na to nie stać
	if PlayerVariables.skill_points <= 0 and !button_pressed:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP


func _make_custom_tooltip(for_text):
	var label = RichTextLabel.new()
	label.text = for_text
	label.fit_content = true
	label.custom_minimum_size.x = 300
	label.bbcode_enabled = true
	return label


func _on_toggled(pressed_button):
	# Odejmuje / dodaje punkty umiejętności
	if pressed_button:
		PlayerVariables.skill_points -= 1
		$ability_buy.play()
	else:
		PlayerVariables.skill_points += 1
		$ability_sell.play()
	# Aktualizuje globalną zmienną umiejętności
	PlayerVariables.abilities[ability_name] = pressed_button



func _on_mouse_entered():
	$hover_tick.play()
