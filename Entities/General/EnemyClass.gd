extends CharacterBody2D
class_name EnemyClass

@onready var qte_hud = get_tree().get_first_node_in_group("QTEHud")
@onready var game_scene = get_tree().get_first_node_in_group("GameScene")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var item_drop = preload("res://Systems/Inventory/Others/dropped_item.tscn")

enum PATHFINDING {WANDER, CHASE, RETREAT}

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
@export var animation_tree: AnimationTree
@export var player_found_timer = Timer
@export var navigation_agent: NavigationAgent2D
@export var vision_cone: PointLight2D
@export var hitbox: Area2D
@export var statemachine: EnemyStateMachine

signal PlayerFound
signal PlayerLost
signal Death

var player_seen: bool = false
var player_in_hitbox: bool = false

func _ready():
	player_found_timer.timeout.connect(on_player_found_timeout)

func handle_movement(_delta):
	var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	velocity = movement_speed * direction
	move_and_slide()
	
	#print("Velocity:", velocity)
	animation_sprite.flip_h = velocity.x < 0

func handle_vision_cone():
	for raycast in vision_cone.get_children():
		if not raycast is RayCast2D:
			continue
		 
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider and collider.is_in_group("Player"):
				PlayerFound.emit()
				break  # Exit early once player is detected	
				
func rotate_vision_cone(target_angle: float, speed: float):
	vision_cone.rotation = lerp_angle(vision_cone.rotation, target_angle, speed)
	print("Pos: ", vision_cone.rotation)
	
func toggle_vision(toggle: bool):
	vision_cone.enabled = toggle
	for raycast in vision_cone.get_children():
		if not raycast is RayCast2D:
			continue  # Skip non-raycast nodes
		else:
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
		health = max(0, health - player_damage)  # Clamp to 0
		print("Enemy Health: ", health)
		
func on_player_found_timeout():
	PlayerLost.emit()
