extends Entity_Class

#------------{ Deer Nodes }------------
@onready var movement_timer = $MovementTimer

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	handle_animation()

func handle_animation():
	if current_state == STATES.IDLE:
		anim_sprite.play("Idle")
	else:
		anim_sprite.play("Run")
	
func _on_player_found():
	movement_speed = 150
	wander_radius *= 2.5
	flee()

func _on_movement_timer_timeout():
	if current_state in [STATES.IDLE, STATES.WANDER] :
		movement_timer.wait_time = randf_range(5, 15)
		wander()

func _on_navigation_agent_2d_target_reached():
	if current_state == STATES.FLEE:
		movement_speed = 75
		wander_radius /= 2.5
		current_state = STATES.IDLE
		movement_timer.start()
		
	if current_state == STATES.WANDER:
		current_state = STATES.IDLE

func _on_death():
	var drop = item_drop.instantiate()  # Create instance
	drop.id = "meat"
	drop.amount = randi_range(1, 3)
	drop.position = global_position  # Set position at the enemy’s location
	
	get_parent().add_child(drop)  # Add to the scene
	
	await get_tree().create_timer(1)
	queue_free()  # Remove the enemy
