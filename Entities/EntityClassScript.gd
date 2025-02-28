extends CharacterBody2D
class_name Entity_Class

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var item_drop = preload("res://Systems/Inventory/Others/dropped_item.tscn")

enum STATES {IDLE, WANDER, SEARCH, PURSUE, FLEE, RETREAT, STUNNED}

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
@export var current_state: STATES

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
signal PlayerEnteredHitbox
signal PlayerExittedHitbox
signal Death
signal Stunned
signal Unstunned

# State variables
const MAX_SUSPICION = 100.0
var player_detected: bool = false
var player_in_hitbox: bool = false
var random_idle_angle: float = 0.0

func _ready():
	add_child(idle_timer)
	idle_timer.one_shot = false
	idle_timer.start(2.0)
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	
	if hitbox:
		hitbox.connect("body_entered", Callable(self, "on_body_entered"))
		hitbox.connect("body_exited", Callable(self, "on_body_exited"))
	
func _physics_process(delta):
	handle_movement(delta)
	if health <= 0:
		Death.emit()
	
func handle_movement(delta):
	var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	#print("Direction:", direction)
	
	if current_state == STATES.IDLE:
		#print("Navigation finished, setting idle.")
		velocity = Vector2.ZERO
		handle_vision_cone(random_idle_angle, delta)
	else:
		#print("Moving towards:", navigation_agent.get_next_path_position())
		velocity = velocity.lerp(direction * movement_speed, acceleration * delta)
		handle_vision_cone(direction.angle(), delta)
		move_and_slide()
	
	#print("Velocity:", velocity)
	handle_animation_direction(direction)

func handle_vision_cone(target_angle: float, delta):
	# Flag to check if player is currently detected in this frame
	var player_currently_detected = false

	# Check if player is within the vision cone using raycasts
	for raycast in vision_cone.get_children():
		var collider = raycast.get_collider()
		if collider == player:
			player_currently_detected = true
			print("Detected Player")
			break  # Exit loop early if player is found

	# Emit signals based on player detection state
	if player_currently_detected and not player_detected:
		PlayerFound.emit()
		player_detected = true
		print("Found Player")
	elif not player_currently_detected and player_detected:
		PlayerLost.emit()
		player_detected = false
		print("Lost Player")

	# Rotate the vision cone towards the target angle
	vision_cone.rotation = lerp_angle(vision_cone.rotation, target_angle, delta * (4 if current_state == STATES.IDLE else 2))

func _on_idle_timer_timeout():
	if current_state == STATES.IDLE:
		# Generate a new random angle for vision cone movement
		random_idle_angle = randf_range(-PI, PI)

func handle_animation_direction(direction):
	anim_sprite.flip_h = velocity.x < 0
	
func set_target_position(target_position: Vector2) -> void:
	if navigation_agent:
		if global_position.distance_to(target_position) > 20:  # Avoid targets too close
			navigation_agent.target_position = target_position
		else:
			print(global_position.distance_to(target_position), " too close, not setting.")
			if current_state == STATES.WANDER:
				wander()
	
func take_damage(playerdamage: int):
	health -= playerdamage
	print("Enemy Health: ", health)
	
func wander():
	current_state = STATES.WANDER
	var random_offset_x = randf_range(-wander_radius, wander_radius)
	var random_offset_y = randf_range(-wander_radius, wander_radius)
	var target_position = global_position + Vector2(random_offset_x, random_offset_y)
	print("Wandering to ", target_position)
	
	set_target_position(target_position)
	
func flee():
	current_state = STATES.FLEE
	var flee_direction = (global_position - get_player_position()).normalized()
	var flee_distance = wander_radius * 2
	var new_position = global_position + flee_direction * flee_distance
	print("Fleeing to ", new_position)
	
	set_target_position(new_position)

func stun(duration: float):
	current_state = STATES.STUNNED
	Stunned.emit()
	movement_speed = 0
	print("Stunned for ", duration)
	
	await get_tree().create_timer(duration).timeout
	Unstunned.emit()
	print("No longer stunned")

func get_player_position() -> Vector2:
	if player:
		return player.global_position
	return global_position

func on_body_entered():
	PlayerEnteredHitbox.emit()
	player_in_hitbox = true

func on_body_exited():
	PlayerExittedHitbox.emit()
	player_in_hitbox = false
