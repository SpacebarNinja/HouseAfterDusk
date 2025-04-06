extends EnemyState

func enter():
	enemy.can_scream = false
	enemy.scream_cooldown.start()
	enemy.movement_speed = 0
	
	scream()

func exit():
	enemy.movement_speed = 100

func scream():
	enemy.animation_tree.get("parameters/playback").travel("Scream")
	await get_tree().create_timer(3).timeout
	transition.emit(self, "roam")
