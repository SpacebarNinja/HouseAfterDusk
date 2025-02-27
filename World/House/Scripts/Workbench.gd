extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

var can_interact: bool = false

func on_intr_area_entered():
	can_interact = true
	handle_text()

func on_intr_area_exited():
	can_interact = false
	pass
	
func handle_text():
	WorldManager.add_interactable("Use Workbench", 1, Callable(self, "_on_use"))
	
func _on_use():
	if HudManager.is_crafting:
		return
	
	else:
		HudManager.is_crafting = true
		WorldManager.StopGeneMovement = true
		WorldManager.Interactables.erase("Use Workbench")

func _process(_delta):
	if not HudManager.is_crafting and can_interact:
		HudManager.camera_movement = true
		HudManager.flashlight_movement = true
		handle_text()
