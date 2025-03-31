extends CharacterBody2D
class_name Entity_Class

@onready var QteHud = get_tree().get_first_node_in_group("QTEHud")
@onready var game_scene = get_tree().get_first_node_in_group("GameScene")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var item_drop = preload("res://Systems/Inventory/Others/dropped_item.tscn")

enum BEHAVIOR_STATES {PROWL, IDLE, WANDER, SEARCH, PURSUE, FLEE, RETREAT, STUNNED}
enum VISION_DIRECTION {RANDOM, PATH, PLAYER}

@export_category("General Enemy Stats")
@export var movement_speed: int = 75
@export var acceleration: int = 2
@export var health: int = 100
@export var attack_damage: int = 0
@export var intelligence: int = 1
@export var suspicion: float = 0

@export_category("Other Stats")
@export var origin_location: Vector2
@export var spawn_location: String
@export var wander_radius: float
@export var current_state: BEHAVIOR_STATES
@export var current_vision_direction: VISION_DIRECTION

@export_category("General Enemy Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var anim_player: AnimationPlayer
@export var anim_tree: AnimationTree
@export var navigation_agent: NavigationAgent2D
@export var vision_cone: PointLight2D
@export var hitbox: Area2D
@onready var idle_timer = Timer.new()

signal PlayerFound
signal PlayerLost
signal Death
signal Stunned
signal Unstunned

# State variables
var player_seen: bool = false
var player_in_hitbox: bool = false
var random_idle_angle: float = 0.0
var previous_state: BEHAVIOR_STATES

func _ready():
	add_child(idle_timer)
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	
func _physics_process(delta):
	handle_movement(delta)
	handle_vision_cone(delta)
	if health <= 0:
		Death.emit()

# { Behavior Logic }------------------------------------------------------------
func handle_movement(delta):
	var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	
	if current_state in [BEHAVIOR_STATES.IDLE, BEHAVIOR_STATES.STUNNED]:
		velocity = Vector2.ZERO
		current_vision_direction = VISION_DIRECTION.RANDOM
		if idle_timer.is_stopped():
			idle_timer.start()
	else:
		#print("Moving towards:", navigation_agent.get_next_path_position())
		velocity = velocity.lerp(direction * movement_speed, acceleration * delta)
		current_vision_direction = VISION_DIRECTION.PATH
		move_and_slide()
	
	#print("Velocity:", velocity)
	anim_sprite.flip_h = velocity.x < 0

func handle_vision_cone(delta):
	var player_currently_detected: bool = false

	for raycast in vision_cone.get_children():
		if not raycast is RayCast2D:
			continue
		
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider and collider.is_in_group("Player"):
				player_currently_detected = true
				break  # Exit early once player is detected

	# Emit signals based on player detection state
	if player_currently_detected != player_seen:
		if player_currently_detected:
			PlayerFound.emit()
			print("Found Player")
		else:
			PlayerLost.emit()
			print("Lost Player")
		player_seen = player_currently_detected

	# Set the vision cone's rotation angle
	var target_angle: float
	if current_vision_direction == VISION_DIRECTION.PLAYER:
		target_angle = (player.global_position).angle()
	elif current_vision_direction == VISION_DIRECTION.PATH:
		target_angle = velocity.angle()
	else:
		target_angle = random_idle_angle

	vision_cone.rotation = lerp_angle(vision_cone.rotation, target_angle, delta * (3 if current_vision_direction == VISION_DIRECTION.RANDOM else 8))

func toggle_vision(toggle: bool):
	vision_cone.enabled = toggle
	for raycast in vision_cone.get_children():
		if not raycast is RayCast2D:
			continue  # Skip non-raycast nodes
		else:
			raycast.enabled = toggle
	
func set_target_position(target_position: Vector2) -> void:
	if navigation_agent:
		if global_position.distance_to(target_position) > 20:  # Avoid targets too close
			navigation_agent.target_position = target_position
		else:
			print(global_position.distance_to(target_position), " too close, not setting.")
	
func take_damage(player_damage: int):
	if player_damage > 0:
		health = max(0, health - player_damage)  # Clamp to 0
		print("Enemy Health: ", health)
	
func manage_suspicion_meter(suspicion_speed: float):
	if player_seen:
		suspicion = clampf(suspicion + suspicion_speed, 0, 100)
	else:
		suspicion = clampf(suspicion - suspicion_speed, 0, 100)
		
# { States Logic }------------------------------------------------------------
func wander():
	current_state = BEHAVIOR_STATES.WANDER
	var random_offset_x = randf_range(-wander_radius, wander_radius)
	var random_offset_y = randf_range(-wander_radius, wander_radius)
	var target_position = global_position + Vector2(random_offset_x, random_offset_y)
	#print("Wandering to ", target_position)
	
	set_target_position(target_position)
	
func flee():
	current_state = BEHAVIOR_STATES.FLEE
	var flee_direction = (global_position - player.global_position).normalized()
	var flee_distance = wander_radius * 2
	var new_position = global_position + flee_direction * flee_distance
	#print("Fleeing to ", new_position)
	
	set_target_position(new_position)

func stun(duration: float):
	current_state = BEHAVIOR_STATES.STUNNED
	Stunned.emit()
	movement_speed = 0
	suspicion = 0
	self_modulate = Color(0.5,1,1)
	#print("Stunned for ", duration)
	
	await get_tree().create_timer(duration).timeout
	Unstunned.emit()
	self_modulate = Color(1,1,1)
	#print("No longer stunned")

func retreat():
	current_state = BEHAVIOR_STATES.RETREAT
	set_target_position(origin_location)
	
# { Signals }------------------------------------------------------------
func _on_idle_timer_timeout():
	if current_state == BEHAVIOR_STATES.IDLE:
		# Generate a new random angle for vision cone movement
		random_idle_angle = randf_range(-PI, PI)
