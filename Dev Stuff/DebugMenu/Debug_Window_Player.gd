extends Panel

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hud = get_tree().get_first_node_in_group("MainHud")

@onready var infinite_sprint_button = $InfiniteSprint

func _on_full_health_pressed():
	player.current_health = player.max_health

func _on_full_hunger_pressed():
	player.current_hunger = player.max_hunger

func _on_removehealth_pressed():
	player.take_damage(10, Vector2.ZERO)
	player.can_take_damage = false

func _on_removehunger_pressed():
	player.current_hunger -= 10
	
func _on_infinite_sprint_toggled(toggled_on):
	if toggled_on:
		player.set_walk_speed(400)
		hud.debug_sprint = true
		infinite_sprint_button.self_modulate = Color(0,1,0, 1)
	else:
		player.set_walk_speed(80)
		hud.debug_sprint = false
		infinite_sprint_button.self_modulate = Color(1,1,1)
