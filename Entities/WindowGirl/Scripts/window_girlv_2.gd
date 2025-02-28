extends Entity_Class

@export_category("Window Chance")
@export var chance_to_window: float = 20

#------------{ Window GIrl Nodes }------------
@onready var wander_timer = $WanderTimer
@onready var search_duration = $SearchDuration
@onready var window_check = $WindowCheck

func _process(delta):
	handle_animation()

func handle_animation():
	if current_state == STATES.IDLE:
		anim_sprite.play("Idle")
	else:
		anim_sprite.play("Run")
		
func check_suspicion_meter(suspicion_speed: float):
	if current_state != STATES.SEARCH:
		return
	
	suspicion = clampf(suspicion + suspicion_speed, 0, MAX_SUSPICION)
	print("Suspicion Level: ", suspicion)
	if suspicion <= 25:
		return
	elif suspicion > 25 and suspicion <= 70 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, "PLAYER_ROOM")
	elif suspicion > 70 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, "PLAYER_CURRENT")
		
func attack():
	anim_sprite.play("Attack")
	await anim_sprite.animation_finished
	if player_in_hitbox:
		player.take_damage(attack_damage, velocity)
	else:
		return
	
func _on_wander_timer_timeout():
	if current_state in [STATES.IDLE, STATES.WANDER] :
		wander_timer.wait_time = randf_range(3, 5)
		wander()

func _on_navigation_agent_2d_target_reached():
	if current_state == STATES.WANDER:
		current_state = STATES.IDLE

func _on_player_found():
	anim_sprite.play("Scream")
	if current_state not in [STATES.PURSUE, STATES.FLEE, STATES.RETREAT]:
		current_state = STATES.PURSUE
		player_detected = true
		
func _on_player_lost():
	if current_state == STATES.PURSUE and player_detected:
		current_state = STATES.SEARCH
		player_detected = false
		
	if search_duration.is_stopped():
		search_duration.start() 
	
func _on_search_duration_timeout():
	current_state = STATES.RETREAT
	set_target_position(origin_location)

func _on_window_check_timeout():
	var chance = randf_range(chance_to_window + 2, 100)
	if chance < 90:
		return
	else:
		window_check.stop()
		GameManager.direct_enemy(self, "CLOSE_WINDOW")

func _on_hitbox_body_entered(body):
	attack()
