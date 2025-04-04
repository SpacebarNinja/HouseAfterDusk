extends EnemyState

var random_idle_angle: float

func enter():
	enemy.animation_tree.get("parameters/playback").travel("Idle")
	enemy.hitbox.connect("body_entered", Callable(self, "_on_hitbox_entered")) 
	enemy.movement_timer.connect("timeout", Callable(self, "_on_movement_timer_timeout")) 
	
	random_idle_angle = randf_range(-45, 45)

func exit():
	enemy.hitbox.disconnect("body_entered", Callable(self, "_on_hitbox_entered"))
	enemy.movement_timer.disconnect("timeout", Callable(self, "_on_movement_timer_timeout")) 
	
func physics_update(delta):
	if enemy.player_seen:
		enemy.rotate_vision_cone(enemy.vision_cone.get_angle_to(player.global_position), 5 * delta)
	else:
		enemy.rotate_vision_cone(random_idle_angle, delta)
		
func _on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "attack")

func _on_movement_timer_timeout() -> void:
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER or enemy.PATHFINDING.ORIGIN:
		enemy.movement_timer.wait_time = 3
	elif enemy.current_pathfinding == enemy.PATHFINDING.CHASE:
		enemy.movement_timer.wait_time = 0.2
	transition.emit(self, "sprint")
