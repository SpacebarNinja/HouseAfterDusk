extends Panel

@onready var map = get_tree().get_first_node_in_group("Map")
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_hide_black_rect_pressed():
	for rects in map.get_black_rect():
		rects.hide()

func _on_show_tilemaps_pressed():
	for tilemaps in map.get_tilemaps():
		tilemaps.show()

func _on_option_button_item_selected(index):
	player.position = map.get_cabin_room(index)


func _on_alt_option_button_item_selected(index):
	player.position = map.get_forest_room(index)
