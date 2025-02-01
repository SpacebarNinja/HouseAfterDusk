# Camera.gd
extends Camera2D

@onready var player = get_tree().get_first_node_in_group("Player")

@export_category("Camera Shake")
@export var randomStrength: float = 20.0
@export var shakeFade: float = 8.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var is_hit: bool = false
var follow_player = true
var camera_anchor = Vector2.ZERO

@export_category("Camera Lean")
@export var x_sensitivity := 4
@export var y_sensitivity := 5
@export var max_lean_distance := 100.0
@export var lean_speed: float = 8

func _ready():
	global_position = player.global_position
	camera_anchor = player.global_position

func apply_shake():
	shake_strength = randomStrength

func _process(delta):
	var rooms_instance = get_node("/root/MainScene/DemoMap2/ROOMS")
	var is_room_bounds_x = rooms_instance.is_room_bounds_x
	var is_room_bounds_y = rooms_instance.is_room_bounds_y
	
	var journal_instance = get_node("/root/MainScene/Hud/MechanicHud/Journal")
	var is_open = journal_instance.is_open

	if is_hit:
		CameraShake(delta)
	else:
		if not is_open:
			CameraLean()

	if not is_room_bounds_x:
		camera_anchor.x = player.global_position.x
	if not is_room_bounds_y:
		camera_anchor.y = player.global_position.y

	RoundPosition()

func RoundPosition():
	var x = round(global_position.x * 10.0) / 10.0
	var y = round(global_position.y * 10.0) / 10.0
	global_position = Vector2(x, y)

func CameraShake(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)
		global_position = camera_anchor + randomcam_offset()

		if shake_strength <= 1:
			is_hit = false

func CameraLean():
	var target_position = camera_anchor
	var mouse_position = get_global_mouse_position()

	var cam_offset = mouse_position - target_position
	if cam_offset.length() > max_lean_distance:
		cam_offset = cam_offset.normalized() * max_lean_distance

	var lean_cam_offset = Vector2(cam_offset.x / x_sensitivity, cam_offset.y / y_sensitivity)
	global_position = global_position.lerp(target_position + lean_cam_offset, lean_speed * get_process_delta_time())

func randomcam_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
