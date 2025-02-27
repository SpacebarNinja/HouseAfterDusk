extends Node2D

func on_intr_area_entered():
	WorldManager.add_interactable("Talk to Alice", 1, Callable(self, "_talk"))

func on_intr_area_exited():
	WorldManager.Interactables.erase("Talk to Alice")
	
#====================================

func _talk():
	DialogueManager.show_dialogue_balloon(load("res://Dialogue/test.dialogue"), "start")
	
