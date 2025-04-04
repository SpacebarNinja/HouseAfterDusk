extends EnemyState

var glich_duration: float

func enter():
	glich_duration = randf_range(enemy.glitch_length, enemy.glitch_length * 3)
	glitch()

func exit():
	enemy.glitch_timer.wait_time = randf_range(enemy.glitch_frequency, enemy.glitch_frequency * 1.5)
	
func glitch():
	enemy.animation_tree.get("parameters/playback").travel("Glitch")
	await get_tree().create_timer(glich_duration).timeout

	transition.emit(self, "idle")
