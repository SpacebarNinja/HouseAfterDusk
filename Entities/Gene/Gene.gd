extends CharacterBody2D

@onready var camera = get_tree().get_first_node_in_group("MainCamera")
@onready var hud = get_tree().get_first_node_in_group("MainHud")
@onready var journal_instance = get_tree().get_first_node_in_group("Journal")

@onready var invulnerability_timer = $Timers/InvulnerabilityTimer
@onready var hunger_timer = $Timers/HungerTimer
@onready var raycast = $RaycastNodes
@onready var animation_handler = $AnimationHandler
@onready var hitbox = $Hitbox

@export_category("Stats")
@export var movement_speed: int = 80
@export var max_health = 100
@export var max_hunger = 55
@export var knockback_power: int = 1000
@export var altmove_sprint_distance = 75

@export_category("Nodes")
@export var flashlight: PointLight2D
@export var audio_list: Array[AudioStreamPlayer2D]

@onready var rooms = get_node("/root/MainScene/DemoMap2/ROOMS")

var current_hunger: int
var current_health: int
var can_take_damage: bool = true
var can_sprint: bool = true
var flashlight_on: bool = true
var equipped_item: bool = false
var current_weapon: String = ""
var distance_to_mouse = 0.0
var is_outside: bool
func _ready():
	current_health = max_health
	current_hunger = max_hunger
	hunger_timer.start()

func set_walk_speed(speed: int):
	movement_speed = speed

func _process(_delta):
	modulate_player()
	rotate_flashlight()
	
	if WorldManager.StopGeneMovement: return
	
	var move_vector = Input.get_vector("WalkLeft", "WalkRight", "WalkUp", "WalkDown")
	velocity = move_vector * movement_speed
	
	var backpack_instance = get_node("/root/MainScene/Hud/MechanicHud/Backpack/BackpackInventory/BackpackSprite")
	var is_hovering_inventory = backpack_instance.is_hovering_inventory
	
	if Input.is_action_pressed("AlternativeMove") and move_vector == Vector2.ZERO and !is_hovering_inventory:
		alternative_move()

	if Input.is_action_pressed("Sprint") and can_sprint:
		sprint()

	if Input.is_action_just_pressed("ToggleFlashlight"):
		toggle_flashlight()

	move_and_slide()
	finding_enemy()

func modulate_player():
	if str(rooms.current_room.name) == 'OUTSIDE':
		is_outside = true
	else:
		is_outside = false
		
	if not WorldManager.is_generator_on and not is_outside:
		self.modulate = Color(1.5, 1.5, 1.5, 1)
	else:
		self.modulate = Color(1, 1, 1, 1)

func alternative_move():
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	distance_to_mouse = global_position.distance_to(mouse_position)

	if not Input.is_action_pressed("Sprint"):
		if distance_to_mouse < 10:
			return
		elif distance_to_mouse < 30:
			global_position = global_position.lerp(mouse_position, 0.5 * get_process_delta_time())
		elif distance_to_mouse > altmove_sprint_distance and can_sprint:
			velocity = direction * (movement_speed * 2)
		else:
			velocity = direction * movement_speed
	elif distance_to_mouse > 30:
		velocity = direction * movement_speed

func update_health_bar(new_health):
	current_health = new_health

func update_hunger_bar(hunger_value):
	current_hunger = hunger_value

func sprint():
	velocity *= 2

func take_damage(enemy_damage: int, enemy_velocity: Vector2):
	if can_take_damage:
		current_health -= enemy_damage
		update_health_bar(current_health)
		can_take_damage = false
		invulnerability_timer.start()
		take_knockback(enemy_velocity)
		hud.reset_blood_overlay()
		camera.apply_shake()
		camera.is_hit = true
		animation_handler.transition("Damaged")

func take_knockback(enemy_velocity: Vector2):
	var knockback_dir = (enemy_velocity - velocity).normalized() * knockback_power
	velocity = knockback_dir
	move_and_slide()

func heal_health(healing: int):
	current_health += healing
	if current_health > max_health:
		current_health = max_health
	update_health_bar(current_health)

func replenish_hunger(food_value: int):
	current_hunger += food_value
	if current_hunger > max_hunger:
		current_hunger = max_hunger
	update_hunger_bar(current_hunger)

func _on_hunger_timer_timeout():
	current_hunger -= 1
	if current_hunger < 0:
		current_hunger = 0
	update_hunger_bar(current_hunger)

func _on_invulnerability_timer_timeout():
	can_take_damage = true

func rotate_flashlight():
	if not journal_instance.is_open and HudManager.flashlight_movement:
		var mouse_position = get_global_mouse_position()
		flashlight.look_at(mouse_position)
		raycast.look_at(mouse_position)

func toggle_flashlight():
	flashlight_on = not flashlight_on
	flashlight.visible = flashlight_on
	if flashlight_on:
		play_audio(0)
	else:
		play_audio(1)

func play_audio(index: int):
	if index >= 0 and index < audio_list.size():
		if not audio_list[index].is_playing():
			audio_list[index].play()

func finding_enemy():
	for raycasts in raycast.get_children():
		var collider = raycasts.get_collider()
		if collider:
			if raycasts.is_colliding() and collider.is_in_group("Enemy"):
				if collider:
					collider.base_bools["is_seen"] = true
				else:
					collider.base_bools["is_seen"] = false

func equip_weapon(has_equipped: bool, weapon: String):
	equipped_item = has_equipped
	current_weapon = weapon

	if equipped_item:
		animation_handler.transition(current_weapon)
	else:
		animation_handler.transition("Basic")
