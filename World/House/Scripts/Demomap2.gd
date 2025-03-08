extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var window_nodes = get_tree().get_nodes_in_group("Window")
@onready var forest_spawn_nodes = %ForestSpawnNodes
@onready var cabin_spawn_nodes = $CabinSpawnNodes
@onready var rooms = $ROOMS

@onready var black_rects = get_tree().get_nodes_in_group("ColorRect(Black)")
@onready var tilemaps = $ROOMS.get_children()
@export var spawn_location: Array[Node2D]


func get_current_room():
	return rooms.current_room.global_position

func get_random_cabin_room():
	var nodes = rooms.cabin_rooms
	if nodes.size() > 0:
		var spawn = nodes[randi() % nodes.size()]
		print("RandomRoom: ", spawn)
		return spawn.global_position

func get_forest_random_spawn_nodes():
	var nodes = forest_spawn_nodes.get_children()
	if nodes.size() > 0:
		var spawn = nodes[randi() % nodes.size()]
		print("ForestSpawn: ", spawn)
		return spawn
		
func get_cabin_random_spawn_nodes():
	var nodes = cabin_spawn_nodes.get_children()
	if nodes.size() > 0:
		var spawn = nodes[randi() % nodes.size()]
		print("CabinSpawn: ", spawn)
		return spawn
	
func get_closest_window(Location: Vector2) -> Vector2:
	var window_list: Array
	
	for node in get_window_nodes():
		var window_location = node.global_position.distance_to(Location)
		var window = {node: window_location}
		window_list.append(window)
		window_list.sort()
		
	print("Window List: ", window_list)
	print("Chosen Window: ", window_list.front())
	return window_list.front()

func get_window_nodes():
	return window_nodes
	
func get_tv_node():
	return spawn_location[0]

func get_cabin_room(room: int):
	var cabin_room = rooms.cabin_rooms[room]
	return cabin_room.global_position

func get_forest_room(room: int):
	var forest_room = rooms.forest_rooms[room]
	return forest_room.global_position

func get_black_rect():
	return black_rects

func get_tilemaps():
	return tilemaps
