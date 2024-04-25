extends Line2D


var pos : Vector2
var sort_pos : Vector2

var neighbors = {}

var restricted : Array[Vector2i]

@export var point_amount : float
@onready var marker = $CharacterBody2D
@onready var parent = get_parent()
@onready var terrain = get_parent().get_parent().get_node("terrain")

@export var debug_mode : bool


func _ready():
	await get_tree().process_frame
	preload_neighbors()
	#var point = Vector2i(-6, 0)
	#print(neighbors[point])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = Vector2.ZERO


func heuristic(start : Vector2i, end : Vector2i):
	var vector = end - start
	return abs(vector.length())


func calculate_trajectory(dir, start_position, speed) -> KinematicCollision2D:
	var collision
	clear_points()
	marker.global_position = start_position
	marker.velocity.y = parent.jump_speed
	for point in point_amount:
		#add_point(marker.global_position)
		marker.velocity.x = dir * speed
		if marker.velocity.y > 0:
			marker.velocity.y += parent.fall_gravity * get_physics_process_delta_time()
		else:
			marker.velocity.y += parent.jump_gravity * get_physics_process_delta_time()
		collision = marker.move_and_collide(marker.velocity * get_physics_process_delta_time(), true)
		if collision:
			break
		marker.global_position += marker.velocity * get_physics_process_delta_time()
	return collision


func assemble_path(came_from, last_point):
	if debug_mode:
		pos = map_to_global(last_point)
		global_position = pos
		add_point(pos)
	clear_points()
	
	var path = [[last_point, "/"]]
	var current = [last_point, "/"]
	while current[0] in came_from.keys():
		current = came_from[current[0]]
		path.push_front(current)
		
		if debug_mode:
			add_point(to_local(map_to_global(current[0])))
	return path


func A_Star(starting_point : Vector2i, goal : Vector2i) -> Array:
	var verification = verify_goal(goal)
	goal = verification
	
	starting_point = verify_goal(starting_point)

	if starting_point == goal:
		return []
	
	var open_set = [starting_point]
	var came_from = {}
	var g_score = {}
	g_score[starting_point] = 0
	var f_score = {}
	f_score[starting_point] = heuristic(starting_point, goal)
	
	while not open_set.is_empty():
		var current = f_score.find_key(f_score.values().min())
		var current_neighbors = neighbors[current]
		if current == goal:
			restricted.erase(goal)
			return assemble_path(came_from, current)
		
		open_set.erase(current)
		f_score.erase(current)
		for neighbor in current_neighbors.keys():
			var distance = 1
			if current_neighbors[neighbor] == "jump_left" or current_neighbors[neighbor] == "jump_right":
				distance += 5
			elif current_neighbors[neighbor] == "jump_slow_left" or current_neighbors[neighbor] == "jump_slow_right":
				distance += 5
				
			var tentative_g_score = g_score[current] + distance
			
			if (g_score.has(neighbor) and tentative_g_score < g_score[neighbor]) or !g_score.has(neighbor):
				came_from[neighbor] = [current, current_neighbors[neighbor]]
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + heuristic(neighbor, goal)
				if not neighbor in open_set:
					open_set.append(neighbor)
	restricted.append(goal)
	return []


func get_neighbors(waypoint : Vector2i) -> Dictionary:
	var waypoints = terrain.get_used_cells(3)
	var found_neighbors = {}
	
	var waypoint_position = map_to_global(waypoint)
	var jump_right = calculate_trajectory(1, waypoint_position, parent.chase_speed)
	var jump_left = calculate_trajectory(-1, waypoint_position, parent.chase_speed)
	var jump_slow_right = calculate_trajectory(1, waypoint_position, parent.chase_speed / 6)
	var jump_slow_left = calculate_trajectory(-1, waypoint_position, parent.chase_speed / 6)
	
	
	if terrain.get_neighbor_cell(waypoint, 0) in waypoints:
		found_neighbors[terrain.get_neighbor_cell(waypoint, 0)] = "walk_right"
	if terrain.get_neighbor_cell(waypoint, 8) in waypoints:
		found_neighbors[terrain.get_neighbor_cell(waypoint, 8)] = "walk_left"
	
	var collision_position
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(waypoint_position + Vector2(10, 0), waypoint_position + Vector2(10, 200), 1)
	var result = space_state.intersect_ray(query)
	if result:
		collision_position = global_to_map(result.position) + Vector2i(0, -1)
		if collision_position in waypoints and collision_position not in found_neighbors:
			found_neighbors[collision_position] = "walk_right"
	
	query = PhysicsRayQueryParameters2D.create(waypoint_position + Vector2(-10, 0), waypoint_position + Vector2(-10, 200), 1)
	result = space_state.intersect_ray(query)
	if result:
		collision_position = global_to_map(result.position) + Vector2i(0, -1)
		if collision_position in waypoints and collision_position not in found_neighbors:
			found_neighbors[collision_position] = "walk_left"
	
	if jump_right:
		collision_position = global_to_map(jump_right.get_position() + Vector2(0, -1))
		if collision_position in waypoints and not found_neighbors.keys().has(collision_position):
			found_neighbors[collision_position] = "jump_right"
	if jump_left:
		collision_position = global_to_map(jump_left.get_position() + Vector2(0, -1))
		if collision_position in waypoints and not found_neighbors.keys().has(collision_position):
			found_neighbors[collision_position] = "jump_left"
	if jump_slow_right:
		collision_position = global_to_map(jump_slow_right.get_position() + Vector2(0, -1))
		if collision_position in waypoints and not found_neighbors.keys().has(collision_position):
			found_neighbors[collision_position] = "jump_slow_right"
	if jump_slow_left:
		collision_position = global_to_map(jump_slow_left.get_position() + Vector2(0, -1))
		if collision_position in waypoints and not found_neighbors.keys().has(collision_position):
			found_neighbors[collision_position] = "jump_slow_left"
	
	return found_neighbors


func preload_neighbors():
	var waypoints = terrain.get_used_cells(3)
	for waypoint in waypoints:
		neighbors[waypoint] = get_neighbors(waypoint)


func verify_goal(goal : Vector2i) -> Vector2i:
	var waypoints = terrain.get_used_cells(3)
	
	if goal not in restricted and goal in waypoints:
		return goal
	else:
		sort_pos = goal
		waypoints.sort_custom(sort_by_distance)
		waypoints = waypoints.filter(func(point): return !restricted.has(point))
		return waypoints[0]


func sort_by_distance(a : Vector2i, b : Vector2i):
	return Vector2(sort_pos).distance_to(a) < Vector2(sort_pos).distance_to(b)


func map_to_global(point : Vector2i) -> Vector2: return terrain.to_global(terrain.map_to_local(point))

func global_to_map(point : Vector2) -> Vector2i: return terrain.local_to_map(terrain.to_local(point))


func _on_restricted_timer_timeout():
	if not restricted.is_empty():
		restricted.remove_at(0)
