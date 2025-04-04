extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")
@onready var hud = get_parent()

@onready var qte_timer = $QTETimer
@onready var qte_bar = $QTEBar

@export_category("QTE Bar")
@export var qte_drain: float = 0.25
@export var qte_gain: float = 7

const QTE_MAX_VALUE = 100
const QTE_MIN_VALUE = 0
const PLAYER_SPEED_DEFAULT = 80
const CAMERA_DEFAULT_ZOOM = 3.2

var qte_active: bool = false
var qte_camera_zoom: float = CAMERA_DEFAULT_ZOOM

signal QTE_Success
signal QTE_Fail

func _process(delta):
	if qte_active:
		handle_qte_speed(delta)
	
func handle_qte_speed(_delta):
	qte_bar.value = clamp(qte_bar.value - qte_drain, QTE_MIN_VALUE, QTE_MAX_VALUE)
	qte_camera_zoom = min(qte_camera_zoom + 0.001, 5)  # Prevent excessive zoom
	camera.target_zoom = Vector2(qte_camera_zoom, qte_camera_zoom)
	
	if Input.is_action_just_pressed("InteractFirst"):
		hud.animation_player.play("quick_time_event_button")
		qte_bar.value = clamp(qte_bar.value + qte_gain, QTE_MIN_VALUE, QTE_MAX_VALUE)
		
	if qte_bar.value >= QTE_MAX_VALUE:
		QTE_Success.emit()
		toggle_hud_visibility(true)
		qte_reset()
		print("Succeeded QTE")
	elif qte_bar.value <= QTE_MIN_VALUE:
		QTE_Fail.emit()
		qte_reset()
		print("Failed QTE")
		
func start_qte():
	qte_active = true
	set_player_state(false)
	toggle_hud_visibility(false)
	
	if qte_timer.is_stopped():
		qte_timer.start()

func qte_reset():
	set_player_state(true)
	hud.current_display("Main")
	qte_bar.value = 50
	qte_camera_zoom = CAMERA_DEFAULT_ZOOM
	camera.target_zoom = Vector2(CAMERA_DEFAULT_ZOOM, CAMERA_DEFAULT_ZOOM)
	qte_timer.stop()
	qte_active = false
	
func _on_qte_timer_timeout():
	if qte_bar.value < QTE_MAX_VALUE:
		QTE_Fail.emit()

func set_player_state(active: bool):
	player.movement_speed = 0 if not active else PLAYER_SPEED_DEFAULT
	player.visible = active

func toggle_hud_visibility(visibility: bool):
	HudManager.clock_visible = visibility
	HudManager.journal_visible = visibility
	HudManager.stats_visible = visibility
	HudManager.inventory_visible = visibility
	HudManager.flashlight_movement = visibility
	HudManager.camera_movement = visibility
	HudManager.interaction_enabled = visibility
