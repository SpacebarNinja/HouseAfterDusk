extends Panel

@onready var hud = get_tree().get_first_node_in_group("Hud")

func _on_show_main_hud_pressed():
	hud.current_display("Main")

func _on_show_qte_hud_pressed():
	hud.current_display("QTE")

func _on_show_crafting_hud_pressed():
	hud.current_display("Crafting")

func _on_show_cooking_hud_pressed():
	hud.current_display("Cooking")
