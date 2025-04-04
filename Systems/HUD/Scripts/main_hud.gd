extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var journal = get_tree().get_first_node_in_group("Journal")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")

@onready var blood_overlay: TextureRect = $"../BGProcessing/BloodOverlay"
@onready var hunger_bar: TextureProgressBar = $MainNodes/HungerBar
@onready var health_bar: TextureProgressBar = $MainNodes/HealthBar
@onready var sprint_bar: TextureProgressBar = $MainNodes/SprintBar
@onready var clock: Control = $MainNodes/Clock
@onready var time_display: Label = $MainNodes/Clock/TimeDisplay

@export_category("Sprint")
@export var tired_color: Color
@export var sprint_bar_decrease_speed := 0.3
@export var sprint_bar_regen_speed := 0.15

@export_category("Fade Settings")
@export var alpha_start: float = 0
@export var alpha_end: float = 1
@export var fade_speed: float = 7.0

var debug_sprint: bool = false
var stopped_dialoguing: bool = false

func _ready():
	if sprint_bar.value >= sprint_bar.max_value - 3:
		sprint_bar.hide()
		
func _process(delta):
	update_health_bar()
	update_hunger_bar()
	update_sprint_bar()
	fade_blood_overlay()
	update_time_display()
	
	if HudManager.stats_visible:
		health_bar.visible = true
		hunger_bar.visible = true
		sprint_bar.visible = true
	else:
		health_bar.visible = false
		hunger_bar.visible = false
		sprint_bar.visible = false
	
	var target_alpha = alpha_start if HudManager.is_dialoguing else alpha_end
	
	health_bar.modulate.a = lerp(health_bar.modulate.a, target_alpha, fade_speed * delta)
	hunger_bar.modulate.a = lerp(hunger_bar.modulate.a, target_alpha, fade_speed * delta)
	clock.modulate.a = lerp(clock.modulate.a, target_alpha, fade_speed * delta)
	
	if HudManager.is_dialoguing:
		WorldManager.StopGeneMovement = true
		HudManager.camera_movement = false
		sprint_bar.visible = false
		stopped_dialoguing = false
	elif not stopped_dialoguing:
		WorldManager.StopGeneMovement = false
		HudManager.camera_movement = true
		sprint_bar.visible = true
		stopped_dialoguing = true
		
func update_time_display():
	time_display.text = WorldManager.DayPart + "\n" + WorldManager.CurrentDate

func _on_backpack_button_pressed():
	if backpack.is_open:
		backpack.close_backpack()
	else:
		backpack.open_backpack()
	backpack.is_open = !backpack.is_open

func _on_journal_button_pressed():
	journal.open_journal_state = not journal.open_journal_state
	if journal.open_journal_state:
		HudManager.inventory_visible = false
		HudManager.stats_visible = false
		WorldManager.StopGeneMovement = true
	else:
		HudManager.inventory_visible = true
		HudManager.stats_visible = true
		WorldManager.StopGeneMovement = false

func update_health_bar():
	health_bar.value = lerp(float(health_bar.value), float(player.current_health), 0.1)
	var health_percentage = player.current_health / health_bar.max_value
	var health_color = Color(1.0, health_percentage, 1.0)
	health_bar.tint_progress = health_color

func update_hunger_bar():
	hunger_bar.value = lerp(float(hunger_bar.value), float(player.current_hunger), 0.1)

func update_sprint_bar():
	var sprint_fade_in_speed = 8.0 * get_process_delta_time()
	var sprint_fade_out_speed = 5.0 * get_process_delta_time()

	var move_vector = Input.get_vector("WalkLeft", "WalkRight", "WalkUp", "WalkDown")

	var is_sprinting = false
	if Input.is_action_pressed("Sprint") and player.can_sprint and move_vector != Vector2.ZERO:
		is_sprinting = true
		
	if debug_sprint:
		return
		
	if is_sprinting:
		sprint_bar.value -= sprint_bar_decrease_speed
		if sprint_bar.value <= 5:
			player.can_sprint = false
			sprint_bar.self_modulate = tired_color
	else:
		sprint_bar.value += sprint_bar_regen_speed

	sprint_bar.value = clamp(sprint_bar.value, 0, sprint_bar.max_value)

	if is_sprinting or sprint_bar.value < sprint_bar.max_value - 3:
		sprint_bar.modulate.a = lerp(sprint_bar.modulate.a, 1.0, sprint_fade_in_speed)
		sprint_bar.show()
	else:
		sprint_bar.modulate.a = lerp(sprint_bar.modulate.a, 0.0, sprint_fade_out_speed)
		if sprint_bar.modulate.a <= 0.01:
			sprint_bar.hide()

	if sprint_bar.value >= sprint_bar.max_value * 0.3:
		player.can_sprint = true
		sprint_bar.self_modulate = Color(1, 1, 1)

func reset_blood_overlay():
	var flip = randi() % 5 + 1
	blood_overlay.show()
	blood_overlay.self_modulate.a = 0.7
	blood_overlay.flip_h = flip < 3
	blood_overlay.flip_v = (int(flip) % 2) == 0

func fade_blood_overlay():
	blood_overlay.self_modulate.a = clamp(blood_overlay.self_modulate.a - 0.01, 0.0, 1.0)
