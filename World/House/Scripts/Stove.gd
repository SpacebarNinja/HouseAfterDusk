extends Node2D

@onready var canvas_hud = get_tree().get_first_node_in_group("CanvasHud")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")
@onready var player = get_tree().get_first_node_in_group("Player")
@export var interaction_area: Area2D

var can_interact: bool = false

func on_intr_area_entered():
	can_interact = true
	handle_text()

func on_intr_area_exited():
	can_interact = false
	
func handle_text():
	WorldManager.add_interactable("Use Stove", 1, Callable(self, "_on_use"))
	
func _on_use():
	if HudManager.is_interacting:
		return
		
	canvas_hud.current_display("Cooking")
	camera.set_position(Vector2(0, 60))
	HudManager.is_interacting = true
	WorldManager.StopGeneMovement = true
	WorldManager.Interactables.erase("Use Stove")
	interaction_area.monitoring = false

func _process(_delta):
	if not HudManager.is_interacting:
		interaction_area.monitoring = true
