extends EnemyState

func enter():
	death()

func death():
	enemy.animation_tree.get("parameters/playback").travel("Death")
