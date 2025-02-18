extends Node2D
class_name AnimationBase

@export var player: CharacterBody2D
@export var animation_handler: AnimationHandler
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

signal transitioned(animation: AnimationBase, new_animation_name: String)

func enter():
	pass

func exit():
	pass
	
func update(_delta: float):
	pass

func physics_Update(_delta: float):
	pass
