extends Enemy_state
class_name Enemy_state_wander

@export var enemy: CharacterBody2D
@export var move_cooldown: Timer
@export var wander_speed: int
@export var wander_radius: int = 100

func enter():
	pass

func exit():
	pass

func get_direction():
	var random_offset_x = randf_range(-wander_radius, wander_radius)
	var random_offset_y = randf_range(-wander_radius, wander_radius)
	var target_position = enemy.global_position + Vector2(random_offset_x, random_offset_y)
	print("TargetPos", target_position)
	enemy.set_target_position(target_position)
	move_cooldown.start()
