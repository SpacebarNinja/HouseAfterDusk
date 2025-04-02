extends EnemyState

@export_category("Prowl Nodes")
@onready var prowl_timer = $ProwlTimer

var corrupted_channels: Array = []

func enter():
	prowl_timer.start()
	corrupted_channels = [1,2,3,4]
	
func _on_prowl_timer_timeout():
	if corrupted_channels.size() > 0:
		corrupted_channels.shuffle()  # Shuffle the array

		var selected_channel = corrupted_channels.pop_front()  # Get and remove the first channel
		print("TvG selected channel ", selected_channel)
		enemy.tv_node.corrupt_channel(selected_channel)

		prowl_timer.start()
	else:
		transition.emit(self, "idle")
		# All channels corrupted, start QTE
