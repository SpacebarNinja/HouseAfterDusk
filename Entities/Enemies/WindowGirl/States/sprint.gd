extends EnemyState

func enter():
	enemy.animation_tree.get("parameters/playback").travel("Sprint")
	enemy.hitbox.connect("body_entered", Callable(self, "on_hitbox_entered")) 
	enemy.navigation_agent.connect("navigation_finished", Callable(self, "on_navigation_finished"))

func exit():
	enemy.hitbox.disconnect("body_entered", Callable(self, "on_hitbox_entered"))
	enemy.navigation_agent.disconnect("navigation_finished", Callable(self, "on_navigation_finished"))
	
func physics_update(delta):
	if enemy.player_seen:
		enemy.rotate_vision_cone(enemy.get_angle_to(player.global_position), 5 * delta)
	else:
		enemy.rotate_vision_cone(enemy.velocity.angle(), 5 * delta)
		
	if enemy.current_pathfinding == enemy.PATHFINDING.CHASE:
		chase()

func sprint():
	match enemy.current_pathfinding:
		enemy.PATHFINDING.WANDER:
			wander()
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
	
func on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "attack")

func _on_movement_timer_timeout() -> void:
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER or enemy.PATHFINDING.ORIGIN:
		enemy.movement_timer.wait_time = 3
	elif enemy.current_pathfinding == enemy.PATHFINDING.CHASE:
		enemy.movement_timer.wait_time = 0.2
	
func on_navigation_finished():
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER or enemy.PATHFINDING.ORIGIN:
		transition.emit(self, "idle")
