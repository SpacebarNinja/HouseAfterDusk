extends EnemyState

var teleport_duration: float

func enter():
	teleport()
	enemy.toggle_vision(false)
	enemy.teleport_duration.connect("timeout", Callable(self, "_on_teleport_duration_timeout"))
	
func exit():
	enemy.teleport_duration.stop()
	enemy.teleport_duration.disconnect("timeout", Callable(self, "_on_teleport_duration_timeout"))
	
func teleport():
	teleport_duration = randf_range(enemy.teleport_min_hide_length, enemy.teleport_max_hide_length)
	enemy.animation_tree.get("parameters/playback").travel("Teleport")
	enemy.teleport_duration.start(teleport_duration)

	match enemy.current_pathfinding:
		enemy.PATHFINDING.WANDER:
			wander()
		enemy.PATHFINDING.CHASE:
			chase()
		enemy.PATHFINDING.ORIGIN:
			retreat()
			
func wander():
	var random_offset_x = randf_range(-enemy.wander_radius, enemy.wander_radius)
	var random_offset_y = randf_range(-enemy.wander_radius, enemy.wander_radius)
	var target_position = enemy.global_position + Vector2(random_offset_x, random_offset_y)
	#print("Wandering to ", target_position)
	
	enemy.set_target_position(target_position)
	print(enemy, " wandering")

func chase():
	enemy.set_target_position(player.global_position)
	print(enemy, " chasing")
	
func retreat():
	enemy.set_target_position(enemy.origin_location)
	print(enemy, " retreating")
	
func _on_teleport_duration_timeout() -> void:
	transition.emit(self, "idle")
