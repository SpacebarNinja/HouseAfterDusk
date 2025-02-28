extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hud = get_tree().get_first_node_in_group("Hud")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")
@onready var animation_player = $AnimationPlayer

@onready var qte_timer = $QTETimer
@onready var qte_bar = $QTEBar

@export_category("QTE Bar")
@export var qte_drain: float = 0.25
@export var qte_gain: float = 7

var qte_active: bool = false
var qte_camera_zoom: float = 3.2

signal QTE_Success
signal QTE_Fail

func _process(delta):
	if qte_active:
		handle_qte_speed(delta)
	
func handle_qte_speed(delta):
	qte_bar.value -= qte_drain
	qte_camera_zoom += 0.001
	camera.zoom = Vector2(qte_camera_zoom,qte_camera_zoom)
	
	if Input.is_action_just_pressed("InteractFirst"):
		animation_player.play("press_button")
		qte_bar.value += qte_gain
		
	if qte_bar.value >= 100:
		QTE_Success.emit()
		qte_reset()
		print("Succeeded Qte")
	elif qte_bar.value <= 0:
		QTE_Fail.emit()
		qte_reset()
		print("Failed Qte")
		
func start_qte():
	player.set_walk_speed(0)
	qte_active = true
	
	show()
	HudManager.clock_visible = false
	HudManager.journal_visible = false
	HudManager.stats_visible = false
	HudManager.inventory_visible = false
	HudManager.flashlight_movement = false
	HudManager.camera_movement = false
	HudManager.interaction_enabled = false
	
	if qte_timer.is_stopped():
		qte_timer.start()
		
	if not animation_player.is_playing():
		animation_player.play("quick_time_event")

func qte_reset():
	hide()
	player.set_walk_speed(80)
	hud.current_display("Main")
	qte_bar.value = 50
	qte_camera_zoom = 3.2
	camera.zoom = Vector2(3.2,3.2)
	qte_timer.stop()
	animation_player.stop()
	qte_active = false
	
func _on_qte_timer_timeout():
	if qte_bar.value < 100:
		QTE_Fail.emit()
