extends Panel

func _on_wg_button_pressed():
	GameManager.spawn_enemy(0)

func _on_tv_g_button_pressed():
	GameManager.spawn_enemy(1)

func _on_doll_button_pressed():
	GameManager.spawn_enemy(2)

func _on_deer_button_pressed():
	GameManager.spawn_enemy(3)
