extends EnemyState

func enter():
	break_in()
	
func break_in():
	match enemy.window.window_direction:
		enemy.window.DIRECTION.TOP:
			enemy.animation_tree.get("parameters/playback").travel("BreakIn_Top")
			print(enemy, " Attacking Top")
		enemy.window.DIRECTION.BOTTOM:
			print(enemy, " Attacking Bottom")
		enemy.window.DIRECTION.LEFT:
			enemy.animation_tree.get("parameters/playback").travel("BreakIn_Side")
			print(enemy, " Attacking Left")
		enemy.window.DIRECTION.RIGHT:
			enemy.animation_tree.get("parameters/playback").travel("BreakIn_Side")
			print(enemy, " Attacking Right")
