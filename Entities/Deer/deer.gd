extends Entity_Class

@export_category("Deer Stats")
@export var fleeing: bool = false

#------------{ Deer Nodes }------------
@onready var wander_timer = $WanderTimer
@onready var flee_duration = $FleeDuration
@onready var dropped_item = preload("res://Systems/Inventory/Others/dropped_item.tscn")


func _process(delta):
	handle_animation()
	if health <= 0:
		death()

func handle_animation():
	if is_idle:
		anim_sprite.play("Idle")
	else:
		anim_sprite.play("Run")

func flee():
	if not fleeing:
		var flee_direction = (global_position - get_player_position()).normalized()
		var flee_distance = wander_radius * 2
		var new_position = global_position + flee_direction * flee_distance
		movement_speed = 150
		wander_radius *= 2.5
		fleeing = true
		set_target_position(new_position)
		flee_duration.start()

func death():
	anim_sprite.self_modulate = Color(0.3,1,1)
	await get_tree().create_timer(2).timeout
	
	dropped_item.instantiate()
	dropped_item.id = "meat"
	dropped_item.amount = randi_range(1,3)
	queue_free()
	
func _on_player_found():
	flee()

func _on_wander_timer_timeout():
	if not fleeing:
		wander_timer.wait_time = randf_range(5, 12)
		wander()

func _on_flee_duration_timeout():
	if fleeing:
		movement_speed = 75
		wander_radius /= 2.5
		fleeing = false
