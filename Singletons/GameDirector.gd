extends Node

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var map = get_tree().get_first_node_in_group("Map")
@onready var game_manager = GameManager

func direct_enemy(enemy, search_chance):
	var target_position = null
	
	if search_chance <= 50:
		target_position = pick_random_cabin_room()
	elif search_chance <= 95:
		target_position = find_player_room()
	elif search_chance <= 100:
		target_position = find_player()
	
	if target_position:
		enemy.set_target_position(target_position)
		print("Target Position selected for enemy with sense (", enemy.sense, "): ", target_position)
	else:
		print("Failed to determine a valid target position for enemy with sense: ", enemy.sense)

		
func pick_random_cabin_room():
	return map.get_random_cabin_room()

func find_player_room():
	return map.get_current_room()

func find_player():
	return player.get_global_position()
