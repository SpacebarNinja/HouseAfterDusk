extends EnemyState

func enter():
	enemy.toggle_vision(true)
	enemy.animation_tree.get("parameters/playback").travel("Idle")
	enemy.glitch_timer.start()
	enemy.hitbox.connect("body_entered", Callable(self, "on_hitbox_entered")) 
	enemy.glitch_timer.connect("timeout", Callable(self, "on_glitch_timer_timeout"))

func exit():
	enemy.glitch_timer.stop()
	enemy.hitbox.disconnect("body_entered", Callable(self, "on_hitbox_entered"))
	enemy.glitch_timer.disconnect("timeout", Callable(self, "on_glitch_timer_timeout"))
	
func on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "quick_time_event")

func on_glitch_timer_timeout():
	transition.emit(self, "glitch")
