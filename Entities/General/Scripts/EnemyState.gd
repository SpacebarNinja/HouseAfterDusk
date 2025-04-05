extends Node
class_name EnemyState

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var game_scene = get_tree().get_first_node_in_group("GameScene")
@export var enemy: EnemyClass

signal transition

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass
