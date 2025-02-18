extends Entity_Class

@export_category("Deer Stats")
@export var fleeing: bool = false

@export_category("Deer Nodes")
@onready var wander_timer = $WanderTimer

func _process(delta):
	handle_animation()

func handle_animation():
	if is_idle:
		play_animation("Idle")
	else:
		play_animation("Run")
	
func _on_player_found():
	flee()

func _on_wander_timer_timeout():
	if not fleeing:
		wander_timer.wait_time = randf_range(5, 15)
		wander()

func flee():
	if not fleeing:
		var flee_direction = (global_position - get_player_position()).normalized()
		var flee_distance = wander_radius * 2
		var new_position = global_position + flee_direction * flee_distance
		fleeing = true
		movement_speed = 150
		wander_radius *= 2.5
		set_target_position(new_position)

func _on_navigation_agent_2d_target_reached():
	if fleeing:
		movement_speed = 75
		movement_speed /= 2.5
		fleeing = false
