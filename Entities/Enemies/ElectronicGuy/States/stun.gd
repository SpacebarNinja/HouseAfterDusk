extends EnemyState

var stun_duration: float = 2.5

func enter():
	enemy.animation_tree.get("parameters/playback").travel("QuickTimeEvent_Stop")
	await get_tree().create_timer(stun_duration).timeout
	unstun()
	
func unstun():
	transition.emit(self, "idle")
