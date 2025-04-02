extends EnemyState

@onready var teleport_timer: Timer = $TeleportTimer

func enter():
	teleport()
	teleport_timer.connect("timeout", Callable(self, "_on_teleport_timer_timeout"))
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER:
		wander()

func exit():
	teleport_timer.stop()
	teleport_timer.disconnect("timeout", Callable(self, "_on_teleport_timer_timeout"))
	
func teleport():
	enemy.animation_tree.get("parameters/playback").travel("Teleport")
	teleport_timer.start(randf_range(enemy.teleport_min_hide_length, enemy.teleport_max_hide_length))
	
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
