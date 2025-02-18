extends CharacterBody2D
class_name Entity_Class

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var director = EnemyDirector

@export_category("General Enemy Stats")
@export var movement_speed: int = 0
@export var acceleration: int = 7
@export var health: int = -1
@export var attack_damage: int = 100
@export var sense: int = 5
@export var intelligence: int = 4
@export var spawn_location: String
@export var wander_radius: float

@export_category("General Enemy Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var navigation_agent: NavigationAgent2D
@export var vision_cone: PointLight2D
@onready var idle_timer = Timer.new()

signal PlayerFound
signal PlayerLost

# State variables
var is_idle: bool = false
var player_detected: bool = false
var random_idle_angle: float = 0.0

func _ready():
	add_child(idle_timer)
	idle_timer.wait_time = 2.0  # Random vision cone movement every 2 seconds
	idle_timer.one_shot = false
	idle_timer.start()
	idle_timer.timeout.connect(_on_idle_timer_timeout)

func _physics_process(delta):
	handle_movement(delta)
	
func handle_movement(delta):
	var direction = navigation_agent.get_next_path_position() - global_position
	print("Direction:", direction)
	direction = direction.normalized()
	
	if navigation_agent.navigation_finished:
		print("Navigation finished, setting idle.")
		is_idle = true
		velocity = Vector2.ZERO
		handle_vision_cone(random_idle_angle, delta)
	else:
		print("Moving towards:", navigation_agent.get_next_path_position())
		is_idle = false
		velocity = velocity.lerp(direction * movement_speed, acceleration * delta)
		handle_vision_cone(direction.angle(), delta)
	
	print("Velocity:", velocity)
	handle_animation_direction(direction)
	move_and_slide()

func handle_vision_cone(target_angle: float, delta):
	# Flag to check if player is currently detected in this frame
	var player_currently_detected = false

	# Check if player is within the vision cone using raycasts
	for raycast in vision_cone.get_children():
		var collider = raycast.get_collider()
		if collider == player:
			player_currently_detected = true
			break  # Exit loop early if player is found

	# Emit signals based on player detection state
	if player_currently_detected and not player_detected:
		PlayerFound.emit()
		player_detected = true
	elif not player_currently_detected and player_detected:
		PlayerLost.emit()
		player_detected = false

	# Rotate the vision cone towards the target angle
	vision_cone.rotation = lerp_angle(vision_cone.rotation, target_angle, delta * (4 if is_idle else 2))

func _on_idle_timer_timeout():
	if is_idle:
		# Generate a new random angle for vision cone movement
		random_idle_angle = randf_range(-PI, PI)

func handle_animation_direction(direction):
	anim_sprite.flip_h = velocity.x < 0
	
func set_target_position(target_position: Vector2) -> void:
	if navigation_agent:
		if global_position.distance_to(target_position) > 20:  # Avoid targets too close
			navigation_agent.target_position = target_position
		else:
			print("Target too close, not setting.")
			
func random_position() -> Vector2i:
	var random_offset_x = randf_range(-wander_radius, wander_radius)
	var random_offset_y = randf_range(-wander_radius, wander_radius)
	var target_position = global_position + Vector2(random_offset_x, random_offset_y)
	print("TargetPos", target_position)
	return target_position
	
func wander():
	set_target_position(random_position())

func play_animation(animation_id: String):
	anim_sprite.play(animation_id)
	
func get_player_position() -> Vector2:
	return player.global_position
