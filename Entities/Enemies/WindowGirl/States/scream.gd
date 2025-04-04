extends EnemyState

func enter():
	enemy.can_scream = false

func scream():
	enemy.animation_tree.get("parameters/playback").travel("Scream")
