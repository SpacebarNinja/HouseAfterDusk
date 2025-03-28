extends Node2D

enum TRANSITION_EFFECT {zoom_in, zoom_out}

@onready var game_scene = get_tree().get_first_node_in_group("GameScene")

@export_category("Exit Information")
@export var text: String
@export var filepath: String
@export var coordinate: Vector2
@export var effect: TRANSITION_EFFECT

func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	pass
	
#====================================

func handle_text():
	WorldManager.add_interactable(text, 2, Callable(self, "transition_scene"))	
	
func transition_scene():
	game_scene.switch_map(filepath, coordinate, str(effect))
