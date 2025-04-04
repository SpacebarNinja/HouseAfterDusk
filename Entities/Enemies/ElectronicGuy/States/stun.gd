extends EnemyState

@export var stun_duration: float = 2.5

func enter():
	enemy.animation_tree.get("parameters/playback").travel("QuickTimeEvent_Stop")
	enemy.player_seen = false
	await get_tree().create_timer(stun_duration).timeout
	unstun()

func exit():
	if enemy.movement_timer.is_stopped():
		enemy.movement_timer.start()

func unstun():
	transition.emit(self, "idle")
