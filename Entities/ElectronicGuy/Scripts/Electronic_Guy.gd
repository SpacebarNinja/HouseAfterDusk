extends Entity_Class

@export_category("ElectronicGuy Stats")
@export var glitch_frequency: int = 2
@export var glitch_length: float = 0.2

@export_category("Teleport Stats")
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 4.0

#------------{ Electronic Guy Nodes }------------
@onready var tv_node = get_tree().get_first_node_in_group("Tv")
@onready var search_cooldown = $SearchCooldown
@onready var movement_timer = $MovementTimer
@onready var teleport_timer = $TeleportTimer
@onready var glitch_timer = $GlitchTimer
@onready var prowl_timer = $ProwlTimer

var corrupted_channels: Array = []
var prowling = true
var is_teleporting = false
var hide_length

func _ready():
	super._ready()
	corrupted_channels = [1,2,3,4]
	
func _physics_process(delta):
	if prowling:
		return
	
	super._physics_process(delta)
	handle_behavior()

func glitch():
	if not is_teleporting and not prowling:
		anim_tree.get("parameters/playback").travel("Glitch")
		await get_tree().create_timer(randf_range(glitch_length, glitch_length * 3)).timeout
		
		anim_tree.get("parameters/playback").travel("Idle")
		glitch_timer.wait_time = randf_range(glitch_frequency, glitch_frequency * 1.5)
		glitch_timer.start()

func start_teleport():
	is_teleporting = true
	anim_tree.get("parameters/playback").travel("Teleport")
	await get_tree().create_timer(0.8).timeout
	teleport_timer.wait_time = randf_range(teleport_min_hide_length, teleport_max_hide_length)
	teleport_timer.start()  # Always restart timer

func end_teleport():
	if is_teleporting:
		is_teleporting = false
		anim_tree.get("parameters/playback").travel("Idle")

func handle_behavior():
	if player_seen:
		current_vision_direction = VISION_DIRECTION.PLAYER
		manage_suspicion_meter(2)
		
	if suspicion >= 80 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, GameManager.LOCATIONS.PLAYER_LOCATION)
		
func on_generator_turn_off() -> void:
	print("Turned Off Generator, Killing TvG")
	queue_free()
	
func _on_player_found():
	if current_state in [BEHAVIOR_STATES.IDLE, BEHAVIOR_STATES.WANDER, BEHAVIOR_STATES.SEARCH]:
		current_state = BEHAVIOR_STATES.PURSUE
		teleport_timer.stop()
		end_teleport()
		manage_suspicion_meter(3)
		
func _on_player_lost():
	if current_state == BEHAVIOR_STATES.PURSUE:
		current_state = BEHAVIOR_STATES.SEARCH
		search_cooldown.start()
		start_teleport()
		set_target_position(player.get_global_position())
	
func on_qte_success():
	anim_tree.get("parameters/playback").travel("Idle")
	stun(2.5)

func on_qte_fail():
	player.take_damage(attack_damage,velocity)

func _on_stunned():
	teleport_timer.stop()

func _on_unstunned():
	start_teleport()

func _on_glitch_timer_timeout():
	glitch()

func _on_teleport_timer_timeout():
	end_teleport()

func _on_search_cooldown_timeout():
	if suspicion > 0:
		manage_suspicion_meter(1)
	else:
		search_cooldown.stop()
		retreat()

func _on_movement_timer_timeout():
	if current_state in [BEHAVIOR_STATES.IDLE, BEHAVIOR_STATES.WANDER]:
		movement_timer.wait_time = 5
		wander()
		
	elif current_state == BEHAVIOR_STATES.PURSUE:
		movement_timer.wait_time = 3
	
	start_teleport()
	movement_timer.start()

func _on_prowl_timer_timeout():
	if corrupted_channels.size() > 0:
		corrupted_channels.shuffle()  # Shuffle the array

		var selected_channel = corrupted_channels.pop_front()  # Get and remove the first channel
		print("TvG selected channel ", selected_channel)
		tv_node.corrupt_channel(selected_channel)

		prowl_timer.start()
	else:
		# All channels corrupted, start QTE
		if not QteHud.is_connected("QTE_Success", Callable(self, "on_qte_success")):
			QteHud.connect("QTE_Success", Callable(self, "on_qte_success"))
		if not QteHud.is_connected("QTE_Fail", Callable(self, "on_qte_fail")):
			QteHud.connect("QTE_Fail", Callable(self, "on_qte_fail"))

		movement_timer.start()
		prowling = false

func _on_hitbox_body_entered(body):
	if body == player and not prowling:
		anim_tree.get("parameters/playback").travel("QuickTimeEvent_Loop")
		await get_tree().create_timer(1).timeout
		GameManager.start_quick_time_event()

func _on_navigation_agent_2d_navigation_finished():
	if current_state == BEHAVIOR_STATES.WANDER:
		current_state = BEHAVIOR_STATES.IDLE
	
	elif current_state == BEHAVIOR_STATES.RETREAT:
		print("TvG Retreated")
		queue_free()
	
	if GameManager.directing_enemy:
		GameManager.directing_enemy = false
