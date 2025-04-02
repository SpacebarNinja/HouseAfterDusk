extends EnemyState

@export_category("ElectronicGuy Stats")
@export var glitch_frequency: int = 2
@export var glitch_length: float = 0.2

func enter():
	glitch()

func glitch():
	enemy.animation_tree.get("parameters/playback").travel("Glitch")
	await get_tree().create_timer(randf_range(glitch_length, glitch_length * 3)).timeout
	
	play_idle_animation()
	glitch_timer.wait_time = randf_range(glitch_frequency, glitch_frequency * 1.5)
	glitch_timer.start()
