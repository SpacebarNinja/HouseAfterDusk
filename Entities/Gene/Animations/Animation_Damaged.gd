extends AnimationBase

func enter():
	animation_player.play("Take_Damage")
	
	await animation_player.animation_finished
	
	animation_handler.transition("Basic")
