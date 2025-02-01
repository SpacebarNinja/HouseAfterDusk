extends Node2D

@onready var hud = get_tree().get_first_node_in_group("Hud")
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
	if hud.current_hud == "Crafting":
		return
	
	else:
		hud.current_display("Crafting")
		WorldManager.StopGeneMovement = true
		WorldManager.Interactables.erase("Use Workbench")

func _input(event):
	if event.is_action_pressed("Escape") and can_interact:
		hud.current_display("Main")
		handle_text()
		WorldManager.StopGeneMovement = false
