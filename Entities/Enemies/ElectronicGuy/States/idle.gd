extends EnemyState

func enter():
	enemy.animation_tree.get("parameters/playback").travel("Idle")
	enemy.glitch_timer.start()
	enemy.movement_timer.start()
	enemy.search_duration.start()
	enemy.hitbox.connect("body_entered", Callable(self, "on_hitbox_entered")) 
	enemy.glitch_timer.connect("timeout", Callable(self, "on_glitch_timer_timeout"))
	enemy.movement_timer.connect("timeout", Callable(self, "on_movement_timer_timeout"))

func exit():
	enemy.glitch_timer.stop()
	enemy.movement_timer.stop()
	enemy.hitbox.disconnect("body_entered", Callable(self, "on_hitbox_entered"))
	enemy.glitch_timer.disconnect("timeout", Callable(self, "on_glitch_timer_timeout"))
	enemy.movement_timer.disconnect("timeout", Callable(self, "on_movement_timer_timeout"))
	
func on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "quick_time_event")

func on_glitch_timer_timeout():
	transition.emit(self, "glitch")
	
func on_movement_timer_timeout():
	if enemy.is_chasing:
		enemy.movement_timer.wait_time = 5
	else:
		enemy.movement_timer.wait_time = 3
		
	transition.emit(self, "teleport")
