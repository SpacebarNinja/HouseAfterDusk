extends Area2D

# NEW INTERACT SYSTEM
@export var sprite: Node2D
@export var interactable_node: NodePath
var intr_display_instance
var interactable

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

	intr_display_instance = get_node("/root/MainScene/Player/CanvasLayer/InteractionDisplay")
	interactable = get_node(interactable_node)
	
func _on_body_entered(body):
	if body.name == 'Player':
		WorldManager.Interactables.clear()
		intr_display_instance.on_intr_area_entered(sprite)
		interactable.on_intr_area_entered()
	
func _on_body_exited(body):
	if body.name == 'Player':
		intr_display_instance.on_intr_area_exited(sprite)
		interactable.on_intr_area_exited()
