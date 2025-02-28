extends Node

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var map = get_tree().get_first_node_in_group("Map")
@onready var hud = get_tree().get_first_node_in_group("MainHud")
@onready var spawn_cooldown = $SpawnCooldown

@export var entity_list: Array[PackedScene]

var directing_enemy: bool = false
var spawned_enemies: Dictionary = {}
var difficulty: float = 1

func spawn_enemy(index):
	if index < 0 or index >= entity_list.size():
		print("Error: Invalid entity_list index.")
		return
	
	var enemy_instance = entity_list[index].instantiate()
	add_child(enemy_instance)
	
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

func kill_enemy(index):
	var enemy_instance = spawned_enemies.get(index, null)
	if enemy_instance and enemy_instance.get_parent() == self:
		enemy_instance.queue_free()
		spawned_enemies.erase(index)
		print("Killed enemy of type:", index)

func kill_all_enemies():
	for index in spawned_enemies.keys():
		var enemy_instance = spawned_enemies[index]
		if enemy_instance and enemy_instance.get_parent() == self:
			enemy_instance.queue_free()
			spawned_enemies.erase(index)
	print("Killed all enemies.")

func _on_spawn_cooldown_timeout():
	var spawn_chance = randf_range(1, 100) * difficulty
	print("Attempting Spawn")
	if spawn_chance >= 90:
		var index = randi_range(1,2)
		spawn_enemy(index)
		print("Spawnin Enemy: ", index, " Success")

func direct_enemy(enemy: Entity_Class, location: String):
	var target_position = null
	directing_enemy = false
	
	match location:
		"RANDOM_CABIN":
			target_position = get_random_cabin_room()
		"PLAYER_ROOM":
			target_position = get_player_room()
		"PLAYER_CURREMT":
			target_position = get_player_location()
		"CLOSE_WINDOW":
			target_position = get_closest_window()
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
		
func get_closest_window():
	return map.get_closest_window()
	
func get_random_cabin_room():
	return map.get_random_cabin_room()

func get_player_room():
	return map.get_current_room()

func get_player_location():
	return player.get_global_position()
