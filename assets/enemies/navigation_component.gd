extends Line2D


@export var point_amount : float
@onready var marker = $CharacterBody2D
@onready var parent = get_parent()
@onready var terrain = get_parent().get_parent().get_node("terrain")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(A_Star(Vector2i(-5, 0), Vector2i(4, -3)))
	pass


func heuristic(start : Vector2i, end : Vector2i):
	var vector = end - start
	return abs(vector.length())


func calculate_trajectory(delta, dir, start_position) -> KinematicCollision2D:
	clear_points()
	var collision
	marker.global_position = start_position
	marker.velocity.y = parent.jump_speed
	for point in point_amount:
		add_point(marker.position)
		marker.velocity.x = dir * parent.chase_speed
		if marker.velocity.y > 0:
			marker.velocity.y += parent.fall_gravity * get_physics_process_delta_time()
		else:
			marker.velocity.y += parent.jump_gravity * get_physics_process_delta_time()
		collision = marker.move_and_collide(marker.velocity * get_physics_process_delta_time())
		if collision:
			break
	return collision


func assemble_path(came_from, current):
	var path = [[current, "/"]]
	current = [current, "/"]
	while current[0] in came_from.keys():
		current = came_from[current[0]]
		path.push_front(current)
	return path


func A_Star(starting_point : Vector2i, goal : Vector2i) -> Array:
	var open_set = [starting_point]
	var came_from = {}
	var g_score = {}
	g_score[starting_point] = 0
	var f_score = {}
	f_score[starting_point] = heuristic(starting_point, goal)
	
	while not open_set.is_empty():
		var current = f_score.find_key(f_score.values().min())
		if current == goal:
			return assemble_path(came_from, current)
		
		open_set.erase(current)
		f_score.erase(current)
		for neighbor in get_neighbors(current).keys():
			var tentative_g_score = g_score[current] + heuristic(current, neighbor)
			if get_neighbors(current)[neighbor] == "jump": tentative_g_score *= 1.5
			if (g_score.has(neighbor) and tentative_g_score < g_score[neighbor]) or !g_score.has(neighbor):
				came_from[neighbor] = [current, get_neighbors(current)[neighbor]]
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + heuristic(neighbor, goal)
				if not neighbor in open_set:
					open_set.append(neighbor)
	return []


func get_neighbors(waypoint : Vector2i) -> Dictionary:
	var neighbors = {}
	var waypoints = terrain.get_used_cells(3)
	
	var waypoint_position = terrain.map_to_local(waypoint) * 0.01
	#print(waypoint_position)
	var jump_collision_right = calculate_trajectory(get_physics_process_delta_time(), 1, waypoint_position)
	var jump_collision_left = calculate_trajectory(get_physics_process_delta_time(), -1, waypoint_position)
	
	if jump_collision_right:
		var collision_position = Vector2i(terrain.local_to_map(terrain.to_local(jump_collision_right.get_position()))) + Vector2i(0, -1)
		if collision_position in waypoints:
			neighbors[collision_position] = "jump"
	if jump_collision_left:
		var collision_position = Vector2i(terrain.local_to_map(terrain.to_local(jump_collision_left.get_position()))) + Vector2i(0, -1)
		if collision_position in waypoints:
			neighbors[collision_position] = "jump"
	
	if terrain.get_neighbor_cell(waypoint, 0) in waypoints:
		neighbors[terrain.get_neighbor_cell(waypoint, 0)] = "walk"
	if terrain.get_neighbor_cell(waypoint, 8) in waypoints:
		neighbors[terrain.get_neighbor_cell(waypoint, 8)] = "walk"
	
	return neighbors
