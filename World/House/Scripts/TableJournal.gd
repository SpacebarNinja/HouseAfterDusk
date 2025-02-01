extends Node2D

@onready var hud = get_tree().get_first_node_in_group("Hud")
@onready var journal = hud.get_node("MechanicHud/Journal")

func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	pass
	
func handle_text():
	WorldManager.add_interactable("Open Journal", 1, Callable(self, "_on_open"))	
	WorldManager.add_interactable("Take Journal", 1, Callable(self, "_on_take"))	

func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		journal.set_can_edit(false)

func _on_take():
	print("taking book")
	
func _on_open():
	if not journal.is_open:
		journal.open_journal()
		journal.set_can_edit(true)
	
