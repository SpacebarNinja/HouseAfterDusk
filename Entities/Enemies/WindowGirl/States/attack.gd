extends EnemyState

func enter():
	attack()
	enemy.animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func exit():
	enemy.animation_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

func attack():
	enemy.animation_tree.get("parameters/playback").travel("Attack")
	player.take_damage("WG", enemy.name, enemy.attack_damage, enemy.velocity)

func _on_animation_finished():
	transition.emit(self, "roam")
