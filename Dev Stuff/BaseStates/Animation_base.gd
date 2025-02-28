extends Node2D
class_name AnimationBase

@onready var player = get_tree().get_first_node_in_group("Player")
@export var animation_handler: AnimationHandler
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var audio_list: Array[AudioStreamPlayer2D]

signal transitioned(animation: AnimationBase, new_animation_name: String)

func enter():
	pass

func exit():
	pass
	
func update(_delta: float):
	pass

func physics_Update(_delta: float):
	pass

func play_audio(index: int, pitch_scale: float):
	if index >= 0 and index < audio_list.size():
		if not audio_list[index].is_playing():
			audio_list[index].play()
			audio_list[index].pitch_scale = pitch_scale
	else:
		print("Invalid audio index: ", index)
