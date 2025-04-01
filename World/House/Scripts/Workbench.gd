extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var interaction_area = $InteractionArea

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
	
	HudManager.is_crafting = true
	WorldManager.StopGeneMovement = true
	WorldManager.Interactables.erase("Use Workbench")
	interaction_area.monitoring = false

func _process(_delta):
	if not HudManager.is_crafting:
		HudManager.camera_movement = true
		HudManager.flashlight_movement = true
		interaction_area.monitoring = true
		handle_text()
