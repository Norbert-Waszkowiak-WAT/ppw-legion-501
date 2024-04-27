extends Control

const IMAGE_SIZE = Vector2(22, 22)

@export var menu_color : Color
@export var cursor_color : Color
@export var separator_color : Color
@export var disabled_color : Color

@export var menu_radius : float = 500
@export var width : float = 300

@export var cursor_length : float = 0.785
@export var cursor_width : float = 10

@export var separator_width : float

@export var icon_scale : float = 1

@export var options : Array[WheelOption]
var selected_option = 0
var disabled_options : Array[WheelOption]


func _draw():
	var direction_to_mouse = Vector2.ZERO.angle_to_point(get_local_mouse_position())
	draw_arc(Vector2(0, 0), menu_radius - (width / 2), 0.25 * TAU, TAU + 0.25 * TAU, 1024, menu_color, width, true)
	
	if !disabled_options.has(options[selected_option]):
		var hover_start = TAU * (selected_option - 1) / options.size() + 0.25 * TAU
		var hover_end = TAU * selected_option / options.size() + 0.25 * TAU
		draw_arc(Vector2(0, 0),
			menu_radius - (width / 2),
			hover_start,
			hover_end,
			128,
			menu_color,
			width,
			true)
	
	if options.size() >= 2:
		for i in range(options.size()):
			if options[i] != null:
				var angle = ((TAU * (i-1) / options.size() + 0.25 * TAU)+(TAU * i / options.size() + 0.25 * TAU)) / 2
				var image_vector = Vector2.from_angle(angle)
				var image_pos = image_vector * (menu_radius - (width / 2))
				var texture_rect = Rect2(image_pos + IMAGE_SIZE * icon_scale / -2, IMAGE_SIZE * icon_scale)
				draw_texture_rect(options[i], texture_rect, false)
	
	for option in disabled_options:
		var index = options.find(option)
		var dis_start = TAU * (index - 1) / options.size() + 0.25 * TAU
		var dis_end = TAU * index / options.size() + 0.25 * TAU
		draw_arc(Vector2(0, 0),
			menu_radius - (width / 2),
			dis_start,
			dis_end,
			128,
			disabled_color,
			width,
			true)
	
	for i in range(options.size()):
		var angle = TAU * i / options.size() + 0.25 * TAU
		var separator_vector = Vector2.from_angle(angle)
		draw_line(separator_vector * (menu_radius - width),
			separator_vector * menu_radius,
			separator_color,
			separator_width,
			true)
	
	draw_arc(Vector2(0, 0),
		menu_radius - width,
		direction_to_mouse - cursor_length,
		direction_to_mouse + cursor_length,
		128,
		cursor_color,
		cursor_width,
		true)

func _process(delta):
	var offset = -(TAU / options.size() - 0.25 * TAU)
	var direction_to_mouse = fposmod(Vector2.ZERO.angle_to_point(get_local_mouse_position()) - offset, TAU)
	var tentative_selected_option = ceil((direction_to_mouse / TAU) * options.size()) - 1
	if !disabled_options.has(options[tentative_selected_option]):
		selected_option = tentative_selected_option
	
	if PlayerVariables.abilities:
		for option in options:
			if PlayerVariables.abilities.keys().has(option.name) and PlayerVariables.abilities[option.name] == false:
				if not disabled_options.has(option):
					disabled_options.append(option)
			else:
				disabled_options.erase(option)
	
	queue_redraw()
