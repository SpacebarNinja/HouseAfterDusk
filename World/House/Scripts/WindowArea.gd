extends Area2D

@export var window: Node2D
var enemy = null
	
func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		if enemy.targets.windows == true:
			enemy = body
			enemy.is_near_window = true
			enemy.set_target_position(window.global_position)
			enemy.window = window
