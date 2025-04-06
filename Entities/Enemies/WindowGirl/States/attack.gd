extends EnemyState

func enter():
	attack()
	
	if enemy.can_scream:
		enemy.can_scream = false
		enemy.scream_cooldown.start()

func attack():
	enemy.animation_tree.get("parameters/playback").travel("Attack")
	player.take_damage("WG", enemy.name, enemy.attack_damage, enemy.velocity)
	
	await get_tree().create_timer(0.3).timeout
	
	transition.emit(self, "roam")
