extends CharacterBody2D
class_name EnemyClass

@onready var qte_hud = get_tree().get_first_node_in_group("QTEHud")
@onready var game_scene = get_tree().get_first_node_in_group("GameScene")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var item_drop = preload("res://Systems/Inventory/Others/dropped_item.tscn")

enum PATHFINDING {WANDER, CHASE, ORIGIN, WINDOW}

@export_category("General Enemy Stats")
@export var movement_speed: int = 75
@export var health: int = 100
@export var attack_damage: int = 0

@export_category("Other Stats")
@export var origin_location: Vector2
@export var spawn_location: String
@export var wander_radius: float
@export var current_pathfinding: PATHFINDING

@export_category("General Enemy Nodes")
@export var animation_sprite: AnimatedSprite2D
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@export var player_found_timer: Timer
@export var navigation_agent: NavigationAgent2D
@export var vision_cone: PointLight2D
@export var hitbox: Area2D
@export var statemachine: EnemyStateMachine

signal PlayerFound
signal PlayerLost
signal Death

var player_seen: bool = false
var player_in_hitbox: bool = false
var random_idle_angle: float

func _ready():
	player_found_timer.timeout.connect(_on_player_found_timeout)

func handle_movement():
	if not navigation_agent:
		return
	
	if not navigation_agent.is_navigation_finished():
		var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
		velocity = movement_speed * direction
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	animation_sprite.flip_h = velocity.x < 0
	
func handle_vision_cone_detection():
	for raycast in vision_cone.get_children():
		if not raycast is RayCast2D:
			continue

		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider and collider.is_in_group("Player"):
				PlayerFound.emit()
				return  # Exit early once player is detected
	
func handle_vision_cone_rotation(delta):
	if player_seen:
		# Look at player
		smooth_look_at(player.global_position, 5 * delta)
	elif velocity == Vector2.ZERO:
		# Idle: Look in a random direction
		var direction = Vector2.RIGHT.rotated(random_idle_angle)
		smooth_look_at(global_position + direction, delta)
	else:
		# Moving: Look in direction of movement
		var direction = velocity.normalized()
		smooth_look_at(global_position + direction, 5 * delta)

func smooth_look_at(target_pos: Vector2, speed: float):
	var target_angle = (target_pos - vision_cone.global_position).angle()
	var new_rotation = lerp_angle(vision_cone.rotation, target_angle, speed)
	vision_cone.rotation = new_rotation
	
func toggle_vision(toggle: bool):
	vision_cone.enabled = toggle
	for raycast in vision_cone.get_children():
		if raycast is RayCast2D:
			raycast.enabled = toggle

func toggle_hitbox(toggle: bool):
	hitbox.monitoring = toggle

func set_target_position(target_position: Vector2) -> void:
	if navigation_agent:
		var distance = global_position.distance_to(target_position)

		if distance < 20:
			var direction = (target_position - global_position).normalized()
			target_position = global_position + direction * 20
		
		navigation_agent.target_position = target_position
		
func take_damage(player_damage: int):
	if player_damage > 0:
		health = max(0, health - player_damage)
		print("Enemy Health: ", health)
		
		if health <= 0:
			Death.emit()
		
func _on_player_found_timeout():
	PlayerLost.emit()
