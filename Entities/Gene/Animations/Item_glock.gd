extends AnimationBase

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var gun_cast = $Guncast
@onready var ray_cast = $Guncast/RayCast2D

const THRESHOLD = 30
var direction = Vector2i(0, 0)
var glock_equipped: bool = false
var can_shoot: bool = true

func enter():
	glock_equipped = true
	print("Holding a glock")
	
func exit():
	glock_equipped = false

func _process(_delta):
	if glock_equipped:
		handle_animation()
		handle_weapon()
	
func handle_weapon():
	var mouse_position = get_global_mouse_position()
	gun_cast.look_at(mouse_position)
	animation_tree.get("parameters/playback").travel("point_gun")
	animation_tree.set("parameters/point_gun/blend_position", direction)
	ray_cast.enabled = true
	
	if Input.is_action_just_pressed("Use"):
		shoot()
		
func shoot():
	var bullet = backpack.find_inventory_item("bullet")
	var collider = ray_cast.get_collider()
	print("Collider: ", collider)
	
	if bullet and can_shoot:
		backpack.remove_inventory_item(bullet, 1)
		play_audio(0, 1)
		can_shoot = false
	
	if ray_cast.is_colliding():
		collider.take_damage(100)
		print("Shot Enemy: ", collider, " for: 100 damage")
	
func handle_animation():
	var screen_size = get_viewport().size
	var center_point = screen_size / 2
	var mouse_position = get_viewport().get_mouse_position()

	var dx = mouse_position.x - center_point.x
	var dy = mouse_position.y - center_point.y
	
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

func _on_shoot_audio_finished():
	can_shoot = true
