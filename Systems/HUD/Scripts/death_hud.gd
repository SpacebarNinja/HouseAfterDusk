extends Control
@onready var main_scene = get_tree().get_first_node_in_group("GameScene")
@onready var death_stats = $DeathStats

enum POSSIBLE_DEATHS {Starvation, TVG, WG}

func get_death_image(death_name: POSSIBLE_DEATHS):
	death_stats.texture = load(str("res://Systems/HUD/Art/Death_By_", death_name ,".png"))

func _on_restart_button_pressed() -> void:
	Load.load_scene(main_scene,"res://Systems/MainMenu/main_menu.tscn")
