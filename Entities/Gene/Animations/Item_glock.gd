extends AnimationBase

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var gun_cast = $Guncast
@onready var ray_cast = $Guncast/RayCast2D
@export var glock_audio_list: Array[AudioStreamPlayer2D]

const THRESHOLD = 30
var direction = Vector2i(0, 0)
var glock_equipped: bool = false

func enter():
	audio_list = glock_audio_list
	glock_equipped = true
	print("Holding a glock")
	
func exit():
	glock_equipped = false

func _process(_delta):
	handle_animation()
	var mouse_position = get_global_mouse_position()
	gun_cast.look_at(mouse_position)
	
	if glock_equipped:
		animation_tree.get("parameters/playback").travel("point_gun")
		animation_tree.set("parameters/point_gun/blend_position", direction)
		ray_cast.enabled = true
		if Input.is_action_just_pressed("Use"):
			shoot()

func shoot():
	var collider = ray_cast.get_collider()
	var bullet = backpack.find_inventory_item("bullet")
	
	if bullet:
		backpack.remove_inventory_item(bullet["item"], 1)
		play_audio(0)
	else:
		return
	
	if collider:
		if ray_cast.is_colliding() and collider.is_in_group("Enemy"):
			print("Shot Enemy")
			collider.take_damage(100)
	
func handle_animation():
	var screen_size = get_viewport().size
	var center_point = screen_size / 2
	var mouse_position = get_viewport().get_mouse_position()

	var dx = mouse_position.x - center_point.x
	var dy = mouse_position.y - center_point.y
	
	gun_cast.look_at(mouse_position)
	
	if abs(dx) > THRESHOLD and abs(dy) > THRESHOLD:
		if dx > 0 and dy < 0:
			direction = Vector2i(1, -1)  # top_right
		elif dx > 0 and dy > 0:
			direction = Vector2i(1, 1)  # bottom_right
		elif dx < 0 and dy < 0:
			direction = Vector2i(-1, -1)  # top_left
		elif dx < 0 and dy > 0:
			direction = Vector2i(-1, 1)  # bottom_left
	elif abs(dx) > abs(dy) and abs(dy) <= THRESHOLD:
		direction = Vector2i(-1, 0) if dx < 0 else Vector2i(1, 0)  # left or right
	elif abs(dy) > abs(dx) and abs(dx) <= THRESHOLD:
		direction = Vector2i(0, -1) if dy < 0 else Vector2i(0, 1)  # top or bottom
		#print(direction)
		
func play_audio(index: int):
	if index >= 0 and index < glock_audio_list.size():
		if not glock_audio_list[index].is_playing():
			glock_audio_list[index].play()
	else:
		print("Invalid audio index: ", index)
