extends EnemyState

var teleport_duration: float

func enter():
	teleport()
	enemy.teleport_timer.connect("timeout", Callable(self, "_on_teleport_timer_timeout"))
	enemy.movement_speed = randf_range(40, 200)
	
func exit():
	if enemy.movement_timer.is_stopped():
		enemy.movement_timer.start()
	enemy.teleport_timer.stop()
	enemy.teleport_timer.disconnect("timeout", Callable(self, "_on_teleport_timer_timeout"))
	enemy.movement_speed = 0
	
func teleport():
	teleport_duration = randf_range(enemy.teleport_min_hide_length, enemy.teleport_max_hide_length)
	
	enemy.animation_tree.get("parameters/playback").travel("Teleport")
	enemy.teleport_timer.start(teleport_duration)
	
	print("PF: ", enemy.current_pathfinding, " Speed: ", enemy.movement_speed)
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER:
		wander()
	elif enemy.current_pathfinding == enemy.PATHFINDING.CHASE:
		chase()
	elif enemy.current_pathfinding == enemy.PATHFINDING.RETREAT:
		retreat()
		
func _on_teleport_timer_timeout() -> void:
	transition.emit(self, "idle")

func wander():
	var random_offset_x = randf_range(-enemy.wander_radius, enemy.wander_radius)
	var random_offset_y = randf_range(-enemy.wander_radius, enemy.wander_radius)
	var target_position = enemy.global_position + Vector2(random_offset_x, random_offset_y)
	#print("Wandering to ", target_position)
	
	enemy.set_target_position(target_position)

func chase():
	enemy.set_target_position(player.global_position)

func retreat():
	enemy.set_target_position(enemy.origin_location)
