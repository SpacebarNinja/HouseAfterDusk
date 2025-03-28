extends Entity_Class

@export_category("ElectronicGuy Stats")
@export var glitch_frequency: int = 2
@export var glitch_length: float = 0.2

@export_category("Teleport Stats")
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 4.0

#------------{ Electronic Guy Nodes }------------
@onready var search_cooldown = $SearchCooldown
@onready var movement_timer = $MovementTimer
@onready var teleport_timer = $TeleportTimer
@onready var glitch_timer = $GlitchTimer
@onready var prowl_timer = $ProwlTimer

var tv_node 
var corrupted_channels: Array = []
var prowling = true
var attacking = false
var is_teleporting = false

func _ready():
	super._ready()
	corrupted_channels = [1,2,3,4]
	tv_node = game_scene.current_map.get_tv_node()
	tv_node.turn_on()
	hide()
	toggle_vision(false)
	
func _physics_process(delta):
	if prowling:
		return
	
	super._physics_process(delta)
	handle_behavior()
	
func glitch():
	if is_teleporting or prowling or attacking:
		return
		
	anim_tree.get("parameters/playback").travel("Glitch")
	await get_tree().create_timer(randf_range(glitch_length, glitch_length * 3)).timeout
	
	play_idle_animation()
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
		play_idle_animation()

func handle_behavior():
	if player_seen:
		current_vision_direction = VISION_DIRECTION.PLAYER
		manage_suspicion_meter(2)
		
	if suspicion >= 80 and not game_scene.directing_enemy:
		game_scene.direct_enemy(self, game_scene.LOCATIONS.PLAYER_LOCATION)

func play_idle_animation():
	anim_tree.get("parameters/playback").travel("Idle")
	
func terminate() -> void:
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
	
func _on_qte_success():
	anim_tree.get("parameters/playback").travel("QuickTimeEvent_Stun")
	stun(2.5)

func _on_qte_fail():
	player.take_damage(attack_damage,velocity)

func _on_stunned():
	teleport_timer.stop()

func _on_unstunned():
	anim_tree.get("parameters/playback").travel("Idle")
	attacking = false
	glitch_timer.start()
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
		if not QteHud.is_connected("QTE_Success", Callable(self, "_on_qte_success")):
			QteHud.connect("QTE_Success", Callable(self, "_on_qte_success"))
		if not QteHud.is_connected("QTE_Fail", Callable(self, "_on_qte_fail")):
			QteHud.connect("QTE_Fail", Callable(self, "_on_qte_fail"))

		prowling = false
		
func _on_hitbox_body_entered(body):
	if body == player and not prowling:
		anim_tree.get("parameters/playback").travel("QuickTimeEvent_Loop")
		attacking = true
		glitch_timer.stop()
		await get_tree().create_timer(1).timeout
		game_scene.start_quick_time_event()

func _on_navigation_agent_2d_navigation_finished():
	if current_state == BEHAVIOR_STATES.RETREAT:
		print("TvG Retreated")
		queue_free()
	
	if game_scene.directing_enemy:
		game_scene.directing_enemy = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Tv_Exit":
		movement_timer.start()
