extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var journal = get_tree().get_first_node_in_group("Journal")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")

@onready var blood_overlay = $BloodOverlay
@onready var health_bar = $HealthBar
@onready var hunger_bar = $HungerBar
@onready var sprint_bar = $SprintBar
@onready var time_display = $Clock/TimeDisplay

@export_category("Sprint")
@export var tired_color: Color
@export var sprint_bar_decrease_speed := 0.3
@export var sprint_bar_regen_speed := 0.15

var debug_sprint: bool = false

func _ready():
	if sprint_bar.value >= sprint_bar.max_value - 3:
		sprint_bar.hide()
		
func _process(_delta):
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
		
func update_time_display():
	time_display.text = WorldManager.DayPart + "\n" + WorldManager.CurrentDate

func _on_backpack_button_pressed():
	if backpack.is_open:
		backpack.close_backpack()
	else:
		backpack.open_backpack()
	backpack.is_open != backpack.is_open

func _on_journal_button_pressed():
	if journal.is_open:
		journal.open_journal_state = false
	else:
		journal.open_journal_state = true
	journal.is_open != journal.is_open

func update_health_bar():
	health_bar.value = player.current_health
	var health_percentage = player.current_health / health_bar.max_value
	var health_color = Color(1.0, health_percentage, 1.0)
	health_bar.tint_progress = health_color

func update_hunger_bar():
	hunger_bar.value = player.current_hunger

func update_sprint_bar():
	var sprint_fade_in_speed = 8.0 * get_process_delta_time()
	var sprint_fade_out_speed = 5.0 * get_process_delta_time()

	var player_instance = get_node("/root/MainScene/Player")
	var distance_to_mouse = player_instance.distance_to_mouse
	var altmove_sprint_distance = player_instance.altmove_sprint_distance
	var move_vector = Input.get_vector("WalkLeft", "WalkRight", "WalkUp", "WalkDown")

	var is_sprinting = false
	if Input.is_action_pressed("Sprint") and player.can_sprint and move_vector != Vector2.ZERO:
		is_sprinting = true
	elif distance_to_mouse > altmove_sprint_distance and Input.is_action_pressed("AlternativeMove") and player.can_sprint:
		is_sprinting = true
	elif Input.is_action_pressed("AlternativeMove") and Input.is_action_pressed("Sprint"):
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
