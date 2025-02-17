extends Node2D
class_name AnimationBase

@export var player: CharacterBody2D
@export var animation_handler: AnimationHandler
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

var audio_list: Array

signal transitioned(animation: AnimationBase, new_animation_name: String)

func enter():
	pass

func exit():
	pass
	
func update(_delta: float):
	pass

func physics_Update(_delta: float):
	pass

func play_audio(index: int):
	if index >= 0 and index < audio_list.size():
		if not audio_list[index].is_playing():
			audio_list[index].play()
	else:
		print("Invalid audio index: ", index)
