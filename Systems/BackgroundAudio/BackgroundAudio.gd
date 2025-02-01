extends Node2D

@onready var audio_listener_2d = $AudioListener2D
@export var Audio_list: Array[AudioStreamPlayer2D]

func play_background_theme(index: int):
	if index >= 0 and index < Audio_list.size():
		if Audio_list[index].is_playing():
			Audio_list[index].stop()
			Audio_list[index].play()
		else:
			Audio_list[index].play()
	else:
		print("Invalid audio index: ", index)
	
	if index >= 1 and index < Audio_list.size():
		audio_listener_2d.make_current()
	else:
		audio_listener_2d.clear_current()
		
func stop_background_theme(index: int):
	if index >= 0 and index < Audio_list.size():
		if Audio_list[index].is_playing():
			Audio_list[index].stop()
