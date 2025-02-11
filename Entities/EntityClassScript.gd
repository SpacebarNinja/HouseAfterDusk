extends CharacterBody2D
class_name Entity_Class

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var director = EnemyDirector

@export_category("General Enemy Stats")
@export var speed: int = 0
@export var acceleration: int = 7
@export var health: int = -1
@export var attack_damage: int = 100
@export var sense: int = 5
@export var intelligence: int = 4
@export var spawn_location: String

@export_category("General Enemy Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var navigation_agent: NavigationAgent2D
@export var vision_cone: PointLight2D

signal PlayerFound

func _physics_process(delta):
	handle_movement(delta)
	handle_animation_direction()
	
func handle_movement(delta):
	var direction = Vector2()
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	handle_vision_cone(direction.angle(), delta)
	move_and_slide()

func handle_vision_cone(direction_angle: float, delta):
	for raycasts in vision_cone.get_children():
		var collider = raycasts.get_collider()
		if collider == player:
			PlayerFound.emit()
		else:
			vision_cone.rotation = lerp_angle(vision_cone.rotation, direction_angle, delta)
			
func handle_animation_direction():
	anim_sprite.flip_h = velocity.x < 0
	
func set_target_position(target_position: Vector2) -> void:
	if navigation_agent:
		navigation_agent.target_position = target_position

func play_animation(animation_id: String):
	anim_sprite.play(animation_id)
	
func get_player_position() -> Vector2i:
	return player.global_position
