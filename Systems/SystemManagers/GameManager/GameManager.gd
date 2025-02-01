extends Node

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var map = get_tree().get_first_node_in_group("Map")
@onready var hud = get_tree().get_first_node_in_group("MainHud")
@onready var world_manager = WorldManager
@onready var spawn_cooldown = $SpawnCooldown

@export var entity_list: Array[PackedScene]

var QTE_succeeded
var QTE_index: int
var QTE_activated: bool = false

var spawned_enemies: Dictionary = {}
var spawned_flags: Dictionary = {}  
var difficulty: float = 1

func _ready():
	print("MAP1: ", map)
	for i in range(entity_list.size()):
		spawned_flags[i] = false

func _process(_delta):
	if QTE_activated:
		if QTE_succeeded == false:
			kill_enemy(QTE_index)
		else:
			player.movement_speed = 1000

func spawn_enemy(index):
	if index < 0 or index >= entity_list.size():
		print("Error: Invalid entity_list index.")
		return
	
	if spawned_flags.get(index, false):
		print("Error: Enemy of type", index, "is already spawned.")
		return
	
	var enemy_instance = entity_list[index].instantiate()
	add_child(enemy_instance)

	match enemy_instance.spawn_location:
		"TV":
			var spawn_node = map.get_tv_node()
			if spawn_node:
				enemy_instance.global_position = spawn_node.global_position
				_register_enemy(index, enemy_instance)
			else:
				print("Error: No valid TV spawn node found.")
		"CABIN":
			var spawn_node = map.get_cabin_spawn_nodes()
			if spawn_node:
				enemy_instance.global_position = spawn_node.global_position
				_register_enemy(index, enemy_instance)
			else:
				print("Error: No valid CABIN spawn node found.")
		"FOREST":
			var spawn_node = map.get_forest_spawn_nodes()
			if spawn_node:
				enemy_instance.global_position = spawn_node.global_position
				_register_enemy(index, enemy_instance)
			else:
				print("Error: No valid FOREST spawn node found.")


func _register_enemy(index, enemy_instance):
	spawned_enemies[index] = enemy_instance
	spawned_flags[index] = true
	print("Spawned enemy of type:", index)

func kill_enemy(index):
	if not spawned_flags.get(index, false):
		print("Error: No enemy of type", index, "is currently spawned.")
		return

	var enemy_instance = spawned_enemies.get(index, null)
	if enemy_instance and enemy_instance.get_parent() == self:
		enemy_instance.queue_free()
		spawned_enemies.erase(index)
		spawned_flags[index] = false
		print("Killed enemy of type:", index)

func kill_all_enemies():
	for index in spawned_enemies.keys():
		var enemy_instance = spawned_enemies[index]
		if enemy_instance and enemy_instance.get_parent() == self:
			enemy_instance.queue_free()
		spawned_flags[index] = false
	spawned_enemies.clear()
	print("Killed all enemies.")

func _on_spawn_cooldown_timeout():
	var spawn_chance = randf_range(1, 100) * difficulty
	print("Attempting Spawn")
	if spawn_chance >= 90:
		var index = randi_range(1,2)
		spawn_enemy(index)
		print("Spawnin Enemy: ", index, " Success")

func start_quick_time_event(index: int):
	QTE_index = index
	QTE_activated = true
	hud.QTE_initiated = true
