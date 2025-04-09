extends Node2D

enum DIRECTION {TOP, BOTTOM, LEFT, RIGHT}
@export var window_direction: DIRECTION

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EnemyClass:
		body.window = self
		print("enemy at ", window_direction, " window")
