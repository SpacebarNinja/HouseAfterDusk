extends EnemyState

var corrupted_channels: Array = []

func enter():
	enemy.global_position = enemy.tv_node.global_position
	enemy.prowl_timer.start()
	enemy.prowl_timer.connect("timeout", Callable(self, "_on_prowl_timer_timeout"))
	corrupted_channels = [1,2,3,4]

func exit():
	enemy.is_wandering = true
	enemy.current_pathfinding = enemy.PATHFINDING.WANDER
	enemy.search_duration.start()
	enemy.prowl_timer.stop()
	enemy.prowl_timer.disconnect("timeout", Callable(self, "_on_prowl_timer_timeout"))

func _on_prowl_timer_timeout():
	if corrupted_channels.size() > 0:
		corrupted_channels.shuffle()  # Shuffle the array

		var selected_channel = corrupted_channels.pop_front()  # Get and remove the first channel
		print("TvG selected channel ", selected_channel)
		enemy.tv_node.corrupt_channel(selected_channel)

		enemy.prowl_timer.start()
	else:
		enemy.animation_tree.get("parameters/playback").travel("Tv_Exit")
		await get_tree().create_timer(5).timeout
		transition.emit(self, "idle")
		# All channels corrupted, start QTE
