extends Control
@onready var main_scene = get_tree().get_first_node_in_group("GameScene")

func _on_restart_button_pressed() -> void:
	Load.load_scene(main_scene,"res://Systems/MainMenu/main_menu.tscn")
