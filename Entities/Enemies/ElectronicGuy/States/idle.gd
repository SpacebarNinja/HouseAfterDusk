extends EnemyState

func enter():
	enemy.animation_tree.get("parameters/playback").travel("Idle")
	enemy.hitbox.connect("body_entered", Callable(self, "on_hitbox_entered"))

func exit():
	enemy.hitbox.disconnect("body_entered", Callable(self, "on_hitbox_entered"))

func on_hitbox_entered(body):
	if body == player:
		transition.emit(self, "quick_time_event")
