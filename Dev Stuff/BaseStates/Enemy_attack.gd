extends Enemy_state
class_name Enemy_state_attack

@onready var player = get_tree().get_first_node_in_group("Player")
@export var enemy: CharacterBody2D

func enter():
	pass

func exit():
	pass

func physics_Update(_delta: float):
	pass

func attack():
	pass

func transition():
	pass
