extends EnemyState

var random_idle_angle: float

func enter():
	enemy.movement_timer.start()
	enemy.hitbox.connect("body_entered", Callable(self, "_on_hitbox_entered")) 
	enemy.movement_timer.connect("timeout", Callable(self, "_on_movement_timer_timeout")) 
	enemy.navigation_agent.connect("navigation_finished", Callable(self, "_on_navigation_finished")) 
	random_idle_angle = randf_range(-45, 45)

func exit():
	enemy.hitbox.disconnect("body_entered", Callable(self, "_on_hitbox_entered"))
	enemy.movement_timer.disconnect("timeout", Callable(self, "_on_movement_timer_timeout"))
	enemy.navigation_agent.disconnect("navigation_finished", Callable(self, "_on_navigation_finished"))  
	
func physics_update(delta):
	handle_animation()
	handle_vision_cone(delta)

func handle_animation():
	if enemy.velocity == Vector2.ZERO:
		enemy.animation_tree.get("parameters/playback").travel("Idle")
	else:
		enemy.animation_tree.get("parameters/playback").travel("Sprint")
		
func handle_vision_cone(delta):
	if enemy.player_seen:
		# Highest priority: Look at player
		enemy.rotate_vision_cone(enemy.vision_cone.get_angle_to(player.global_position), 5 * delta)
	elif enemy.velocity == Vector2.ZERO:
		# Idle: rotate randomly
		enemy.rotate_vision_cone(random_idle_angle, delta)
	else:
		# Moving: face direction
		enemy.rotate_vision_cone(enemy.velocity.angle(), 5 * delta)
		
func handle_path_finding():
	match enemy.current_pathfinding:
		enemy.PATHFINDING.CHASE:
			chase()
		enemy.PATHFINDING.WANDER:
			wander()
		enemy.PATHFINDING.ORIGIN:
			retreat()
	enemy.movement_timer.start()
	
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
	
func _on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "attack")

func _on_movement_timer_timeout() -> void:
	if enemy.current_pathfinding == enemy.PATHFINDING.WANDER or enemy.current_pathfinding == enemy.PATHFINDING.ORIGIN:
		enemy.movement_timer.wait_time = 3
	elif enemy.current_pathfinding == enemy.PATHFINDING.CHASE:
		enemy.movement_timer.wait_time = 0.2
	handle_path_finding()

func _on_navigation_finished():
	enemy.velocity = Vector2.ZERO
