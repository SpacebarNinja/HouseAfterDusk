extends Area2D

# NEW INTERACT SYSTEM
@export var sprite: Node2D
@export var interactable_node: NodePath
var intr_display_instance
var interactable

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	interactable = get_node_or_null(interactable_node)
	intr_display_instance = get_node_or_null("/root/MainScene/Player/CanvasLayer/InteractionDisplay")

	if not intr_display_instance:
		print("InteractionDisplay not found! Retrying after scene loads...")
		call_deferred("_delayed_setup")

func _delayed_setup():
	intr_display_instance = get_node_or_null("/root/MainScene/Player/CanvasLayer/InteractionDisplay")

	
func _on_body_entered(body):
	if body.name == 'Player':
		WorldManager.Interactables.clear()
		intr_display_instance.on_intr_area_entered(sprite)
		interactable.on_intr_area_entered()
	
func _on_body_exited(body):
	if body.name == 'Player':
		intr_display_instance.on_intr_area_exited(sprite)
		interactable.on_intr_area_exited()
