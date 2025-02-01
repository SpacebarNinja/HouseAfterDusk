extends Panel

func _on_wg_button_toggled(toggled_on):
	if toggled_on:
		GameManager.spawn_enemy(0)
		print("Spawning WG")
	else:
		GameManager.kill_enemy(0)
		print("Killing WG")

func _on_tvg_button_toggled(toggled_on):
	if toggled_on:
		GameManager.spawn_enemy(1)
	else:
		GameManager.kill_enemy(1)
		
func _on_doll_button_toggled(toggled_on):
	if toggled_on:
		GameManager.spawn_enemy(2)
	else:
		GameManager.kill_enemy(2)
