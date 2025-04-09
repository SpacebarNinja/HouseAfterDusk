extends Node2D

@onready var forest_spawn_nodes = %ForestSpawnNodes
@onready var window_nodes = get_tree().get_nodes_in_group("Window")
	
func get_forest_random_spawn_nodes():
	var nodes = forest_spawn_nodes.get_children()
	if nodes.size() > 0:
		var spawn = nodes[randi() % nodes.size()]
		print("ForestSpawn: ", spawn)
		return spawn
		
func get_floor_tile():
	return $Floor

func get_closest_window(location: Vector2) -> Node2D:
	var window_list: Array = []

	for node in get_window_nodes():
		var dist = node.global_position.distance_to(location)
		window_list.append({ "node": node, "distance": dist })

	window_list.sort_custom(func(a, b): return a["distance"] < b["distance"])

	if window_list.is_empty():
		return null  # Or handle however you like
		
	print("Chosen Window: ", window_list.front())

	return window_list.front()["node"]
	
func get_window_nodes():
	return window_nodes
