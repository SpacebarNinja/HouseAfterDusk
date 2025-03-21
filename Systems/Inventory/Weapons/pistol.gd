extends BaseWeapon

@onready var bullet_scene: PackedScene = preload("res://Systems/Inventory/Weapons/bullet.tscn")
@onready var shoot_audio: AudioStreamPlayer2D = $Shoot_Audio
@onready var gun_point: Node2D = $Gun_Point

@export_category("Pistol Stats")
@export var ammo_count: int = 0

const THRESHOLD = 30
var direction = Vector2i(0, 0)

func _process(_delta):
	handle_animation()
	handle_weapon()
	
func handle_weapon():
	animation_tree.get("parameters/playback").travel("point_gun")
	animation_tree.set("parameters/point_gun/blend_position", direction)
	
	if Input.is_action_just_pressed("Use"):
		shoot()
		
func shoot():
	if not bullet_scene or not backpack:
		return  # Prevent crashes

	var bullet_item = backpack.find_inventory_item("bullet")
	if bullet_item and can_attack:
		var bullet_instance = bullet_scene.instantiate()
		add_child(bullet_instance)
		
		backpack.remove_inventory_item(bullet_item, 1)
		shoot_audio.play()
		can_attack = false

		# Set bullet position & direction
		bullet_instance.global_position = gun_point.global_position  # Spawn at gun
		bullet_instance.shoot_towards(get_global_mouse_position())  # Move toward mouse

		start_attack_cooldown()
	
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
