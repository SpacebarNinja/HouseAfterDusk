extends Entity_Class

@export_category("Window Chance")
@export var chance_to_window: float = 20

var actions = {"Attack": false, "Scream": false, "BreakIn": false}

#------------{ Window GIrl Nodes }------------
@onready var movement_timer = $MovementTimer
@onready var search_cooldown = $SearchCooldown
@onready var window_check = $WindowCheck
@onready var scream_cooldown = $ScreamCooldown

var can_scream: bool = true
var finding_window: bool = false

func _ready():
	super._ready()
	
func _physics_process(delta):
	super._physics_process(delta)
	handle_animation()
	handle_behavior(delta)
		
func handle_animation():
	for key in actions.keys():
		if actions[key]:
			anim_tree.get("parameters/playback").travel(key)  # Directly play action animation
			return  # Prevent movement animations from overriding

	if velocity == Vector2.ZERO:
		anim_tree.get("parameters/playback").travel("Idle")
	else:
		anim_tree.get("parameters/playback").travel("Run")
		
func attack():
	if player_in_hitbox:
		player.take_damage(attack_damage, velocity)
	else:
		return
		
func handle_behavior(_delta):
	if player_seen:
		current_vision_direction = VISION_DIRECTION.PLAYER
		manage_suspicion_meter(2)
		if can_scream:
			actions["Scream"] = true
			can_scream = false
			scream_cooldown.start()
		
	if suspicion >= 80 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, GameManager.LOCATIONS.PLAYER_LOCATION)

func handle_actions(action):
	actions[action] = not actions[action]

func _on_player_found():
	if current_state in [BEHAVIOR_STATES.IDLE, BEHAVIOR_STATES.WANDER, BEHAVIOR_STATES.SEARCH]:
		current_state = BEHAVIOR_STATES.PURSUE
		manage_suspicion_meter(10)
		
func _on_player_lost():
	if current_state == BEHAVIOR_STATES.PURSUE:
		current_state = BEHAVIOR_STATES.SEARCH
		search_cooldown.start()
		GameManager.direct_enemy(self, GameManager.LOCATIONS.PLAYER_LOCATION)

func _on_death():
	anim_tree.get("parameters/playback").travel("Death")

func _on_window_check_timeout():
	if randf() * 100 <= chance_to_window:
		window_check.stop()
		GameManager.direct_enemy(self, GameManager.LOCATIONS.CLOSEST_WINDOW)
		finding_window = true
		
func _on_scream_cooldown_timeout():
	can_scream = true

func _on_search_cooldown_timeout():
	if suspicion > 0:
		manage_suspicion_meter(3)
	else:
		search_cooldown.stop()
		window_check.stop()
		scream_cooldown.stop()
		retreat()

func _on_movement_timer_timeout():
	if current_state in [BEHAVIOR_STATES.IDLE, BEHAVIOR_STATES.WANDER]:
		movement_timer.wait_time = 5
		wander()
		
	elif current_state == BEHAVIOR_STATES.PURSUE:
		movement_timer.wait_time = 3

	movement_timer.start()

func _on_hitbox_body_entered(body):
	if body == player:
		player_in_hitbox = true
		actions["Attack"] = true

func _on_hitbox_body_exited(body):
	if body == player:
		player_in_hitbox = false
		actions["Attack"] = false

func _on_navigation_agent_2d_navigation_finished():
	if current_state == BEHAVIOR_STATES.WANDER:
		current_state = BEHAVIOR_STATES.IDLE
		
	elif current_state == BEHAVIOR_STATES.RETREAT:
		queue_free()
		
	if GameManager.directing_enemy:
		GameManager.directing_enemy = false
