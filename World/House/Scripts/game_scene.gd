extends Node

enum LOCATIONS {RANDOM_CABIN, PLAYER_ROOM, PLAYER_LOCATION, CLOSEST_WINDOW}

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")
@onready var hud = get_tree().get_first_node_in_group("CanvasHud")
@onready var transition_node = get_node_or_null("Hud/BGProcessing/Transition")

@onready var spawn_cooldown = $SpawnCooldown

@export var entity_list: Array[PackedScene]

var current_map: Node

var zoom_out_amount = -1.0
var zoom_in_amount = 1.0
var original_zoom = 3.2

var directing_enemy: bool = false
var spawned_enemies: Dictionary = {}
var difficulty: float = 1

func _ready():
	initialize_enemy_list()
	get_current_map()
	
func initialize_enemy_list():
	for enemy in entity_list:
		var enemy_name = get_scene_name(enemy)
		spawned_enemies[enemy_name] = {
			"spawned": false,
			"amount": 0,
			"instances": []  # Initialize an empty array for tracking instances
		}

# { Map Logic }------------------------------------------------------------
func switch_map(new_map_path: String, player_position: Vector2, transition_type: String = ""):
	if not ResourceLoader.exists(new_map_path):
		print("❌ ERROR: Map scene does not exist! Check path:", new_map_path)
		return
	
	# TRANSITION
	if hud:
		transition_node.visible = true
		hud.animation_player.play("scene_transition_in")
		await hud.animation_player.animation_finished

	# Get MainScene correctly
	var main_scene = get_node_or_null("/root/MainScene")
	if not main_scene:
		print("❌ ERROR: MainScene not found in tree!")
		return
	
	# Get current map, making sure it's actually a child of MainScene
	for child in main_scene.get_children():
		if child.is_in_group("Map"):  # Ensure maps are grouped properly
			current_map = child
			break

	if current_map:
		main_scene.remove_child(current_map)
		current_map.queue_free()
	else:
		print("⚠️ WARNING: No current map found, switching anyway.")

	# Load new map safely
	var new_map = load(new_map_path)
	if not new_map or not new_map.can_instantiate():
		print("❌ ERROR: Failed to load map:", new_map_path)
		return

	var new_map_instance = new_map.instantiate()
	main_scene.add_child(new_map_instance)  # Correctly add it under MainScene
	new_map_instance.set_owner(main_scene)  # Ensure proper scene ownership
	get_current_map()
	
	# Move player safely
	if player:
		player.global_position = player_position

	# Reset camera position & apply transition zoom effect
	HudManager.camera_movement = false
	
	if camera:
		if transition_type == 'zoom_in':
			camera.apply_zoom_transition(Vector2(original_zoom + zoom_out_amount, original_zoom + zoom_out_amount))
		else:
			camera.apply_zoom_transition(Vector2(original_zoom + zoom_in_amount, original_zoom + zoom_in_amount))
		camera.reset_camera_position(player.global_position)

	if hud:
		hud.animation_player.play("scene_transition_out")
		await hud.animation_player.animation_finished
		transition_node.visible = false
	
func get_spawn_node(spawn_location):
	match spawn_location:
		"TV":
			if current_map.has_method("get_tv_node"):
				return current_map.get_tv_node()
		"CABIN":
			if current_map.has_method("get_cabin_random_spawn_nodes"):
				return current_map.get_cabin_random_spawn_nodes()
		"FOREST":
			if current_map.has_method("get_forest_random_spawn_nodes"):
				return current_map.get_forest_random_spawn_nodes()
	return null
	
# { Enemy Logic }----------------------------------------------------------
func spawn_enemy(index):
	if index < 0 or index >= entity_list.size():
		print("Error: Invalid entity_list index.")
		return
	
	var enemy_instance = entity_list[index].instantiate()
	add_child(enemy_instance)

	var spawn_node = get_spawn_node(enemy_instance.spawn_location)
	if spawn_node:
		var enemy_name = get_scene_name(entity_list[index])
		
		# Use get() with default value to simplify dictionary updates
		var enemy_data = spawned_enemies.get(enemy_name, {"spawned": true, "amount": 0, "instances": []})
		enemy_data["amount"] += 1
		enemy_data["instances"].append(enemy_instance)
		spawned_enemies[enemy_name] = enemy_data
		
		enemy_instance.global_position = spawn_node.global_position
		enemy_instance.origin_location = spawn_node.global_position
		print("Spawned enemy:", enemy_name)
	else:
		print("Error: No valid", enemy_instance.spawn_location, "spawn node found.")
	debug_spawned_enemies()

func kill_enemy(index):
	if index < 0 or index >= entity_list.size():
		print("Error: Invalid entity_list index.")
		return
	
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
	
	#debug_spawned_enemies()
	print("Killed all enemies.")

func direct_enemy(enemy: Entity_Class, location: LOCATIONS):
	var target_position = null

	match location:
		LOCATIONS.RANDOM_CABIN:
			target_position = current_map.get_random_cabin_room()
		LOCATIONS.PLAYER_ROOM:
			target_position = current_map.get_current_room()
		LOCATIONS.PLAYER_LOCATION:
			target_position = player.global_position
		LOCATIONS.CLOSEST_WINDOW:
			target_position = current_map.get_closest_window(enemy.global_position)

	if target_position:
		enemy.set_target_position(target_position)
		directing_enemy = true
		print("Directing enemy to:", target_position, "based on location:", location)
	else:
		print("Failed to determine a valid target position for enemy:", enemy.name)

# { Extra Logic }----------------------------------------------------------
func start_quick_time_event():
	hud.current_display("QTE")
		
func get_scene_name(packed_scene: PackedScene) -> String:
	if packed_scene.resource_path:
		return packed_scene.resource_path.get_file().get_basename()
	return "Unknown Scene"
	
func get_current_map():
	current_map = get_tree().get_first_node_in_group("Map")
	
func debug_spawned_enemies():
	for key in spawned_enemies.keys():
		print(key, " ->")
		var enemy_data = spawned_enemies[key]
		for k in enemy_data.keys():
			print("\t", k, ": ", enemy_data[k])
			
# { Signals }----------------------------------------------------------
func _on_spawn_cooldown_timeout():
	var spawn_chance = randf_range(1, 100) * difficulty
	print("Attempting Spawn")
	if spawn_chance >= 90:
		spawn_enemy(randi_range(0,3))
