extends Panel

@onready var player = get_tree().get_first_node_in_group("Player")

func _on_full_health_pressed():
	player.current_health = player.max_health

func _on_full_hunger_pressed():
	player.current_hunger = player.max_hunger

func _on_removehealth_pressed():
	player.take_damage(10, Vector2.ZERO)
	player.can_take_damage = false

func _on_removehunger_pressed():
	player.current_hunger -= 10
