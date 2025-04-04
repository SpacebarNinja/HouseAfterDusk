extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D
@onready var main_hud = get_tree().get_first_node_in_group("MainHud")
@onready var canvas_hud = get_tree().get_first_node_in_group("CanvasHud")
@onready var journal_instance = get_tree().get_first_node_in_group("Journal")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var StepParticleScene = preload("res://Systems/Particles/StepParticle.tscn")

const max_health = 100
const max_hunger = 55

@export_category("Gene Stats")
@export var movement_speed: int = 80
@export var current_health: int = 100
@export var current_hunger: int = 55
@export var knockback_power: int = 1000
@export var can_take_damage: bool = true
@export var ALTERNATIVE_MOVE_SPRINT_DISTANCE: int = 100

#------------{ Gene Nodes }------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var equipped_item_visual: Sprite2D = $EquippedItemVisual
@onready var hunger_timer: Timer = $Timers/HungerTimer
@onready var idle_timer: Timer = $Timers/IdleTimer
@onready var vision_cone: PointLight2D = $VisionCone
@onready var equipped_item = $EquippedItem

var can_sprint: bool = true
var can_spawn_particle: bool = true
var flashlight_on: bool = false
var equipped_weapon: bool = false
var current_weapon: String = ""
var is_outside: bool = false
var right_click_moving: bool = false
var is_alt_sprinting: bool = false

func _process(_delta):
	modulate_player()
	handle_vision_cone()
	
	if WorldManager.StopGeneMovement:
		return

	var used_alternative = alternative_movement()

	if not used_alternative:
		var move_vector = Input.get_vector("WalkLeft", "WalkRight", "WalkUp", "WalkDown")
		velocity = move_vector * movement_speed
		is_alt_sprinting = false

	if equipped_weapon:
		animation_tree.active = false
		animated_sprite.hide()
		equipped_item_visual.hide()
	else:
		animation_tree.active = true
		animated_sprite.show()
		equipped_item_visual.show()
		if not used_alternative:
			handle_movement_animation()

	move_and_slide()

	if Input.is_action_just_pressed("ToggleFlashlight"):
		toggle_flashlight()

func handle_movement_animation():
	if velocity == Vector2.ZERO:
		animation_tree.get("parameters/Movement/playback").travel("Idle")
	elif Input.is_action_pressed("Sprint") and can_sprint:
		sprint()
	else:
		animation_tree.get("parameters/Movement/playback").travel("Walk")
	
	var horizontal_input = Input.get_action_strength("WalkRight") - Input.get_action_strength("WalkLeft")

	if horizontal_input == -1:
		animated_sprite.flip_h = true
		equipped_item_visual.flip_h = true
	elif horizontal_input == 1:
		animated_sprite.flip_h = false
		equipped_item_visual.flip_h = false
		
func spawn_particle():
	if not can_spawn_particle:
		return  # Prevent multiple spawns while on cooldown

	can_spawn_particle = false

	# Spawn the step particle
	var step_particle_instance = StepParticleScene.instantiate()
	if randi() % 100 < 30:
		step_particle_instance.amount = 2
	add_child(step_particle_instance)
	step_particle_instance.emitting = true
	step_particle_instance.z_index = -1

	# Introduce a random cooldown before enabling spawning again
	var random_cooldown = randf_range(0.2, 0.6)
	var timer = get_tree().create_timer(random_cooldown)
	await timer.timeout
	
	can_spawn_particle = true
	
func modulate_player():
	var rooms = get_node_or_null("/root/MainScene/MapCabin/ROOMS")
	if rooms:
		var outside_status = rooms.is_outside
		if outside_status != is_outside:  # Update only when it changes
			is_outside = outside_status
			
			if not WorldManager.is_generator_on and not is_outside:
				self.modulate = Color(1.5, 1.5, 1.5, 1)
			else:
				self.modulate = Color(1, 1, 1, 1)

func sprint():
	if velocity.length() > 0:  # Ensure player is actually moving
		velocity = velocity.normalized() * movement_speed * 2
		animation_tree.get("parameters/Movement/playback").travel("Sprint")
		spawn_particle()
	
func take_damage(enemy_damage: int, enemy_velocity: Vector2):
	if can_take_damage:
		current_health = clampi(current_health - enemy_damage, 0, max_health)
		take_knockback(enemy_velocity)
		main_hud.reset_blood_overlay()
		camera.apply_shake()
		camera.is_hit = true
		animation_tree.get("parameters/playback").travel("Damaged")
		
		if current_health <= 0:
			death()
			
func take_knockback(enemy_velocity: Vector2):
	var knockback_dir = (global_position - enemy_velocity).normalized()
	velocity = knockback_dir * knockback_power
	move_and_slide()

func replenish_health(healh_gain: int):
	current_health = clampi(current_health + healh_gain, 0, max_health)

func replenish_hunger(hunger_gain: int):
	current_hunger = clampi(current_hunger + hunger_gain, 0, max_hunger)

func handle_vision_cone():
	if not journal_instance.is_open and HudManager.flashlight_movement:
		var mouse_position = get_global_mouse_position()
		vision_cone.look_at(mouse_position)
		
	for raycast in vision_cone.get_children():
		if not raycast is RayCast2D:
			continue  # Skip non-raycast nodes
			
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider and collider.is_in_group("Enemy"):
				print("Found enemy: ", collider)
					
func toggle_flashlight():
	
	flashlight_on = not flashlight_on
	vision_cone.enabled = flashlight_on

func equip_weapon(weapon_check: bool, weapon_id: String):
	# Load the weapon scene
	var weapon_scene = load(str("res://Systems/Inventory/Weapons/", weapon_id, ".tscn"))
	current_weapon = weapon_id
	equipped_weapon = weapon_check
	
	if weapon_check:
		if weapon_scene is PackedScene:
			var weapon_instance = weapon_scene.instantiate()
			current_weapon = weapon_id
			
			equipped_item.add_child(weapon_instance)

			# Debugging prints
			print("Equipping Item:", weapon_id)
		else:
			print("Invalid weapon scene:", weapon_scene)
	else:
		print("Unequipping Item:", weapon_id, weapon_check)
		if equipped_item.get_child_count() > 0:
			var weapon_instance = equipped_item.get_child(0)
			equipped_item.remove_child(weapon_instance)

func death():
	animation_tree.get("parameters/playback").travel("Death")
	camera.target_zoom = Vector2(5.8, 5.8)
	camera.offset = Vector2(32, 0)
	canvas_hud.current_display("Death")
	vision_cone.enabled = false
	HudManager.camera_movement = false
	set_collision_layer_value(2, false)
	
func alternative_movement() -> bool:
	var distance_to_mouse = global_position.distance_to(get_global_mouse_position())
	var altmove_sprint_distance = ALTERNATIVE_MOVE_SPRINT_DISTANCE
	var alternative_move_pressed = Input.is_action_pressed("AlternativeMove")
	var sprint_pressed = Input.is_action_pressed("Sprint")
	
	var backpack_instance = get_node_or_null("/root/MainScene/Hud/MechanicHud/Backpack/BackpackInventory/BackpackSprite")
	var is_hovering_inventory = backpack_instance and backpack_instance.get("is_hovering_inventory")

	var no_keyboard_input = Input.get_vector("WalkLeft", "WalkRight", "WalkUp", "WalkDown") == Vector2.ZERO

	if alternative_move_pressed and no_keyboard_input and distance_to_mouse > 10 and not is_hovering_inventory:
		right_click_moving = true

		var mouse_position = get_global_mouse_position()
		var mouse_direction = (mouse_position - global_position).normalized()

		if mouse_direction.x < 0:
			animated_sprite.flip_h = true
			equipped_item_visual.flip_h = true
		else:
			animated_sprite.flip_h = false
			equipped_item_visual.flip_h = false

		var is_sprinting = (sprint_pressed or distance_to_mouse > altmove_sprint_distance) and can_sprint
		if is_sprinting:
			velocity = mouse_direction * movement_speed * 2
			animation_tree.get("parameters/Movement/playback").travel("Sprint")
			spawn_particle()
			is_alt_sprinting = true
		else:
			velocity = mouse_direction * movement_speed
			animation_tree.get("parameters/Movement/playback").travel("Walk")
			is_alt_sprinting = false

		return true  # Indicate that alternative movement handled it
	else:
		right_click_moving = false
		return false
func _on_hunger_timer_timeout():
	current_hunger = clampi(current_hunger - 1, 0, max_hunger)

func _on_idle_timer_timeout():
	var alt_idle = randf()
	if alt_idle > 0.65:
		animation_tree.set("parameters/Movement/Idle/Alternative1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	elif alt_idle > 0.9:
		animation_tree.set("parameters/Movement/Idle/Alternative2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	idle_timer.wait_time = randf_range(6, 10)  # Cleaner way to set timer
	idle_timer.start()
