extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@export var hiding_spot: Node2D

var is_hidden: bool = false

func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	pass
	
func handle_text():
	if is_hidden:
		WorldManager.Interactables.erase("Hide In Closet")
		WorldManager.add_interactable("Leave Closet", 1, Callable(self, "_on_exit"))
	else:
		WorldManager.Interactables.erase("Leave Closet")
		WorldManager.add_interactable("Hide In Closet", 1, Callable(self, "_on_hide"))
	
	
func _on_hide():
	is_hidden = true
	player.position = hiding_spot.global_position
	player.animation_handler.current_animation.anim_sprite.self_modulate.a = 0.3
	WorldManager.StopGeneMovement = true
	handle_text()
	

func _on_exit():
	is_hidden = false
	player.animation_handler.current_animation.anim_sprite.self_modulate.a = 1
	WorldManager.StopGeneMovement = false
	handle_text()
