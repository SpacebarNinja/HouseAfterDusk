extends EnemyState

func enter():
	glitch()

func glitch():
	enemy.animation_tree.get("parameters/playback").travel("Glitch")
	await get_tree().create_timer(randf_range(enemy.glitch_length, enemy.glitch_length * 3)).timeout
	
	enemy.glitch_timer.wait_time = randf_range(enemy.glitch_frequency, enemy.glitch_frequency * 1.5)
	transition.emit(self, "idle")
