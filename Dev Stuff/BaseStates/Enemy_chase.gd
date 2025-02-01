extends Enemy_state
class_name Enemy_state_chase

@onready var player = get_tree().get_first_node_in_group("Player")
@export var enemy: CharacterBody2D
@export var move_cooldown: Timer
@export var pursue_speed: int

func enter():
	pass
	
func physics_Update(_delta: float):
	pass

func exit():
	pass

func find_target():
	pass

func on_move_timer_timeout():
	pass
