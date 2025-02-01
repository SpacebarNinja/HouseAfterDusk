extends Node2D

@onready var backpack = get_tree().get_first_node_in_group("Backpack")

@export var window_location: Vector2
@export var tilemap: TileMapLayer

var is_open: bool = false

func _on_interact():
	var item = backpack.get_equipped_item()
	if item and item.get_property("id", "") == 'key':
		#open and close
		pass
	else:
		#clear buttons
		pass
func _on_open_window_button_pressed():
	is_open = true
	tilemap.set_cell(window_location, 1, Vector2i(9,7))
	print("Opening Window")
	
func _on_close_window_button_pressed():
	is_open = false
	tilemap.set_cell(window_location, 1, Vector2i(9,10))
	print("Closing Window")
