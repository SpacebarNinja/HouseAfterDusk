extends Entity_Class

@export_category("ElectronicGuy Stats")
@export var glitch_frequency: int = 2
@export var glitch_length: float = 0.2

@export_category("Teleport Stats")
@export var teleport_min_speed: int = 80
@export var teleport_max_speed: int = 150
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 4.0

#------------{ Electronic Guy Nodes }------------
@onready var teleport_timer = $TeleportTimer
@onready var glitch_timer = $GlitchTimer
@onready var search_cooldown = $SearchCooldown
@onready var movement_timer = $MovementTimer

var is_teleporting = false
var hide_length

func _ready():
	super._ready()
	print(anim_tree.get_animation_list(), " | ", anim_tree.get_animation_library_list())
	QteHud.connect("QTE_Success", Callable(self, "on_qte_success"))
	QteHud.connect("QTE_Fail", Callable(self, "on_qte_fail"))

	wander()

func _physics_process(delta):
	super._physics_process(delta)
	if player_detected:
		var player_angle = rad_to_deg(get_angle_to(get_player_position()))
		handle_vision_cone(player_angle, delta)
		check_suspicion_meter(0.01)

func glitch():
	if not is_teleporting:
		anim_tree.get("parameters/playback").travel("Glitch")
		await get_tree().create_timer(randf_range(glitch_length, glitch_length * 3)).timeout
		
		anim_tree.get("parameters/playback").travel("Idle")
		glitch_timer.wait_time = randf_range(glitch_frequency, glitch_frequency * 1.5)
		glitch_timer.start()

func start_teleport():
	is_teleporting = true
	anim_tree.get("parameters/playback").travel("Teleport")
	await anim_tree.animation_finished
	movement_speed = randi_range(teleport_min_speed, teleport_max_speed)  # Set random teleport speed
	teleport_timer.wait_time = randf_range(teleport_min_hide_length, teleport_max_hide_length)
	teleport_timer.start()  # Always restart timer

func end_teleport():
	if is_teleporting:
		is_teleporting = false
		movement_speed = 0
		anim_tree.get("parameters/playback").travel("Idle")
		
func check_suspicion_meter(suspicion_speed: float):
	if current_state != STATES.SEARCH:
		return
	
	suspicion = clampf(suspicion + suspicion_speed, 0, MAX_SUSPICION)
	print("Suspicion Level: ", suspicion)
	if suspicion > 25 and suspicion <= 50 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, "RANDOM_CABIN")
	elif suspicion > 50 and suspicion <= 90 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, "PLAYER_ROOM")
	elif suspicion > 90 and not GameManager.directing_enemy:
		GameManager.direct_enemy(self, "PLAYER_CURRENT")

func _on_player_found():
	player_detected = true
	teleport_timer.stop()
	if current_state == STATES.WANDER:
		current_state = STATES.PURSUE
		
func _on_player_lost():
	if current_state == STATES.PURSUE and player_detected:
		current_state = STATES.SEARCH
		player_detected = false
		teleport_timer.start()
		
func _on_glitch_timer_timeout():
	glitch()

func _on_teleport_timer_timeout():
	end_teleport()

func _on_search_cooldown_timeout():
	if suspicion > 0:
		check_suspicion_meter(-3)
	else:
		search_cooldown.stop()

func _on_movement_timer_timeout():
	start_teleport()
	
	if current_state == STATES.WANDER:
		movement_timer.wait_time = 5
		wander()
		
	if current_state == STATES.PURSUE:
		movement_timer.wait_time = 3
	
func _on_player_entered_hitbox():
	GameManager.start_quick_time_event()
	
func on_qte_success():
	stun(5)
	suspicion = 0

func on_qte_fail():
	player.take_damage(attack_damage,velocity)

func _on_stunned():
	teleport_timer.stop()

func _on_unstunned():
	teleport_timer.start()
