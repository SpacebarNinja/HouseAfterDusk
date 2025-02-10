extends Entity_Class

@export_category("Deer Stats")
@export var wander_radius: int = 100

@export_category("Deer Nodes")
@onready var wander_timer = $WanderTimer
@onready var idle_timer = $IdleTimer

func _process(delta):
	handle_animation()

func handle_animation():
	if not idle_timer.is_stopped():
		play_animation("Idle")
	elif velocity != Vector2.ZERO:
		play_animation("Run")

func random_position() -> Vector2i:
	var random_offset_x = randf_range(-wander_radius, wander_radius)
	var random_offset_y = randf_range(-wander_radius, wander_radius)
	var target_position = global_position + Vector2(random_offset_x, random_offset_y)
	print("TargetPos", target_position)
	return target_position
	
func _on_player_found():
	var player_position = get_player_position()
	var new_position = random_position()
	if player_position.x < 0:
		set_target_position(Vector2(abs(new_position.x), new_position.y))
	else:
		set_target_position(Vector2(new_position.x * -1, new_position.y))

func _on_idle_timer_timeout():
	set_target_position(random_position())
	wander_timer.start()

func _on_wander_timer_timeout():
	var idle_chance = randf_range(1,100)
	
	if idle_chance > 70:
		idle_timer.start()
	else:
		wander_timer.start()
