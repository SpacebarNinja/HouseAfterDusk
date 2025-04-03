extends EnemyState

func enter():
	enemy.qte_hud.connect("QTE_Success", Callable(self, "_on_qte_success"))
	enemy.qte_hud.connect("QTE_Fail", Callable(self, "_on_qte_fail"))
	
	enemy.animation_tree.get("parameters/playback").travel("QuickTimeEvent_Start")
	game_scene.start_quick_time_event()
	
func exit():
	enemy.qte_hud.disconnect("QTE_Success", Callable(self, "_on_qte_success"))
	enemy.qte_hud.disconnect("QTE_Fail", Callable(self, "_on_qte_fail"))
	
func _on_qte_success():
	enemy.animation_tree.get("parameters/playback").travel("QuickTimeEvent_Stop")
	transition.emit(self, "stun")

func _on_qte_fail():
	enemy.animation_tree.get("parameters/playback").travel("Idle")
	player.take_damage(enemy.attack_damage,enemy.velocity)
	
