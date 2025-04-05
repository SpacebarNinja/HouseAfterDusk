extends EnemyState

func enter():
	attack()
	
func attack():
	enemy.animation_tree.get("parameters/playback").travel("Attack")
	player.take_damage("WG", enemy.name, enemy.attack_damage,enemy.velocity)
	transition.emit(self, "roam")
