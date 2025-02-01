extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hud = get_tree().get_first_node_in_group("Hud")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")
@onready var animation_player = $AnimationPlayer

@onready var qte_timer = $QTETimer
@onready var qte_button = $QTEBUTTON/QTEButton
@onready var qte_bar = $QTEBar

@export_category("QTE Bar")
@export var qte_drain: float = 0.25
@export var qte_gain: float = 7

var qte_camera_zoom: float = 3.2

func _process(_delta):
	if hud.current_hud == "QTE":
		player.movement_speed = 0
		if qte_timer.is_stopped():
			qte_timer.start()
		if not animation_player.is_playing():
			animation_player.play("quick_time_event")
			
		qte_bar.value -= qte_drain
		qte_camera_zoom += 0.001
		camera.zoom = Vector2(qte_camera_zoom,qte_camera_zoom)
		
		if Input.is_action_just_pressed("Interact"):
			animation_player.play("press_button")
			qte_bar.value += qte_gain
		
		if qte_bar.value >= 100:
			qte_success()
		elif qte_bar.value <= 0:
			qte_fail()
		
func _on_qte_timer_timeout():
	if qte_bar.value < 100:
		qte_fail()

func qte_reset():
	hud.current_display("Main")
	qte_bar.value = 50
	qte_camera_zoom = 3.2
	camera.zoom = Vector2(3.2,3.2)
	qte_timer.stop()
	animation_player.stop()

func qte_success():
	qte_reset()
	player.movement_speed = 80
	GameManager.QTE_succeeded = true
	print("Succeeded Qte")

func qte_fail():
	player.take_damage(1,Vector2(0,0))
	qte_reset()
	GameManager.QTE_succeeded = false
	print("Failed Qte")
