extends EnemyState

var random_idle_angle: float

func enter():
	enemy.toggle_vision(true)
	enemy.toggle_hitbox(true)
	enemy.animation_tree.get("parameters/playback").travel("Idle")
	enemy.glitch_timer.start()
	enemy.hitbox.connect("body_entered", Callable(self, "_on_hitbox_entered")) 
	enemy.movement_timer.connect("timeout", Callable(self, "_on_movement_timer_timeout")) 
	enemy.glitch_timer.connect("timeout", Callable(self, "_on_glitch_timer_timeout"))
	
	random_idle_angle = randf_range(-45, 45)

func exit():
	enemy.toggle_vision(false)
	enemy.toggle_hitbox(false)
	enemy.glitch_timer.stop()
	enemy.hitbox.disconnect("body_entered", Callable(self, "_on_hitbox_entered"))
	enemy.movement_timer.disconnect("timeout", Callable(self, "_on_movement_timer_timeout")) 
	enemy.glitch_timer.disconnect("timeout", Callable(self, "_on_glitch_timer_timeout"))
		
func _on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "quick_time_event")

func _on_glitch_timer_timeout():
	transition.emit(self, "glitch")

func _on_movement_timer_timeout() -> void:
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER:
		enemy.movement_timer.start(5)
	elif enemy.current_pathfinding == enemy.PATHFINDING.ORIGIN:
		enemy.movement_timer.start(3)
	elif enemy.current_pathfinding == enemy.PATHFINDING.CHASE:
		enemy.movement_timer.start(1.5)
	transition.emit(self, "teleport")
