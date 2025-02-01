extends Enemy_state
class_name Enemy_state_pursue

@onready var player = get_tree().get_first_node_in_group("Player")
@export var enemy: CharacterBody2D
@export var move_timer: Timer
@export var pursue_duration: Timer
@export var hit_box: Area2D
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

func on_pursue_duration_timeout():
	pass
