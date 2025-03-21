extends Node2D
@onready var transition_animation = get_node("/root/MainScene/Hud/BGProcessing/Transition/AnimationPlayer")
@onready var transition_node = get_node("/root/MainScene/Hud/BGProcessing/Transition")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var door_entrance = $DoorEntrance
@onready var forest_spawn_nodes = %ForestSpawnNodes
# PRELOADS
const MAP_CABIN = preload("res://World/House/Scenes/map_cabin.tscn")
const MAP_OUTSIDE = preload("res://World/House/Scenes/map_outside.tscn")

func _ready():
	door_entrance.connect("area_entered", Callable(self, "_on_cabin_area_entered"))

func _on_cabin_area_entered(_area):
	SceneManager.switch_map("res://World/House/Scenes/map_cabin.tscn", Vector2(192, 272), "zoom_out")
	
func get_forest_random_spawn_nodes():
	var nodes = forest_spawn_nodes.get_children()
	if nodes.size() > 0:
		var spawn = nodes[randi() % nodes.size()]
		print("ForestSpawn: ", spawn)
		return spawn
