extends Node2D

@onready var forest_spawn_nodes = %ForestSpawnNodes
	
func get_forest_random_spawn_nodes():
	var nodes = forest_spawn_nodes.get_children()
	if nodes.size() > 0:
		var spawn = nodes[randi() % nodes.size()]
		print("ForestSpawn: ", spawn)
		return spawn
