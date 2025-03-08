extends Node

enum LOCATIONS {RANDOM_CABIN, PLAYER_ROOM, PLAYER_LOCATION, CLOSEST_WINDOW}

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var map = get_tree().get_first_node_in_group("Map")
@onready var hud = get_tree().get_first_node_in_group("MainHud")
@onready var spawn_cooldown = $SpawnCooldown

@export var entity_list: Array[PackedScene]

var directing_enemy: bool = false
var spawned_enemies: Dictionary = {}
var difficulty: float = 1

func _ready():
	initialize_enemy_list()

func initialize_enemy_list():
	for enemy in entity_list:
		var enemy_name = get_scene_name(enemy)
		spawned_enemies[enemy_name] = {
			"spawned": false,
			"amount": 0,
			"instances": []  # Initialize an empty array for tracking instances
		}

func spawn_enemy(index):
	if index < 0 or index >= entity_list.size():
		print("Error: Invalid entity_list index.")
		return
	
	var enemy_instance = entity_list[index].instantiate()
	enemy_instance.set_meta("scene_ref", entity_list[index])  # Store PackedScene reference
	add_child(enemy_instance)
	
	var enemy_name = get_scene_name(entity_list[index])
	
	if enemy_name in spawned_enemies:
		spawned_enemies[enemy_name]["spawned"] = true
		spawned_enemies[enemy_name]["amount"] += 1
		spawned_enemies[enemy_name]["instances"].append(enemy_instance)  # Store instance
	else:
		spawned_enemies[enemy_name] = {
			"spawned": true,
			"amount": 1,
			"instances": [enemy_instance]
		}

	# Assign spawn position
	var spawn_node = null
	match enemy_instance.spawn_location:
		"TV":
			spawn_node = map.get_tv_node()
		"CABIN":
			spawn_node = map.get_cabin_random_spawn_nodes()
		"FOREST":
			spawn_node = map.get_forest_random_spawn_nodes()
			
	if spawn_node:
		enemy_instance.global_position = spawn_node.global_position
		enemy_instance.origin_location = spawn_node.global_position
	else:
		print("Error: No valid ", enemy_instance.spawn_location, "spawn node found.")
	debug_spawned_enemies()

func kill_enemy(index):
	var enemy_name = get_scene_name(entity_list[index])
	if enemy_name in spawned_enemies:
		if spawned_enemies[enemy_name]["instances"].size() > 0:
			var enemy_instance = spawned_enemies[enemy_name]["instances"].pop_front()  # Remove first found instance
			enemy_instance.queue_free()
			
			spawned_enemies[enemy_name]["amount"] -= 1
			if spawned_enemies[enemy_name]["amount"] <= 0:
				spawned_enemies[enemy_name]["spawned"] = false
		
			print("Killed enemy of type:", enemy_name)
		else:
			print("Error: No instances of", enemy_name, "found.")
	else:
		print("Error: Enemy type not found in spawned_enemies dictionary.")
	debug_spawned_enemies()


func kill_all_enemies():
	for enemy_name in spawned_enemies.keys():
		for enemy_instance in spawned_enemies[enemy_name]["instances"]:
			enemy_instance.queue_free()  # Remove all instances
		spawned_enemies[enemy_name]["instances"].clear()  # Clear instance list
		spawned_enemies[enemy_name]["spawned"] = false
		spawned_enemies[enemy_name]["amount"] = 0
	
	debug_spawned_enemies()
	print("Killed all enemies.")
	
func debug_spawned_enemies():
	print(spawned_enemies)

func _on_spawn_cooldown_timeout():
	var spawn_chance = randf_range(1, 100) * difficulty
	print("Attempting Spawn")
	if spawn_chance >= 90:
		spawn_enemy(randi_range(0,3))

func direct_enemy(enemy: Entity_Class, location: LOCATIONS):
	var target_position = null
	
	match location:
		LOCATIONS.RANDOM_CABIN:
			target_position = map.get_random_cabin_room()
		LOCATIONS.PLAYER_ROOM:
			target_position = map.get_current_room()
		LOCATIONS.PLAYER_LOCATION:
			target_position = player.global_position
		LOCATIONS.CLOSEST_WINDOW:
			target_position = map.get_closest_window(enemy.global_position)
	print("Directing to: ", location)
	
	if target_position:
		enemy.set_target_position(target_position)
		directing_enemy = true
		print("Target Position selected for enemy with sense (", enemy.suspicion, "): ", target_position)
	else:
		print("Failed to determine a valid target position for enemy with sense: ", enemy.suspicion)

func start_quick_time_event():
	if not QteHud.qte_active:
		QteHud.start_qte()
	else:
		print("Currently in a QTE")
		
func get_scene_name(packed_scene: PackedScene) -> String:
	if packed_scene.resource_path:
		return packed_scene.resource_path.get_file().get_basename()
	return "Unknown Scene"
