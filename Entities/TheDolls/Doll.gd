extends CharacterBody2D

@export_category("General Enemy Stats")
@export var speed: int = 1
@export var acceleration: int = 2
@export var health: int = -1
@export var attack_damage: int = 100
@export var sense: int = 5
@export var intelligence: int = 4
@export var spawn_location: String

@onready var anim_sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var vision_cone = $Vision


func _ready():
	pass

func _physics_process(delta):
	handle_movement(delta)
	#print('timer: ', teleport_timer)
	#print('teleporting?: ', is_teleporting)
	#print('hide_length: ', hide_length)

func handle_movement(delta):
	var direction = Vector2()
	nav.target_position = player.global_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	handle_vision_cone(direction.angle())
	move_and_slide()

func handle_vision_cone(direction_angle: float):
	for raycasts in vision_cone.get_children():
		var collider = raycasts.get_collider()
		if collider == player:
			vision_cone.look_at(player.global_position)
		else:
			vision_cone.rotation = lerp(vision_cone.rotation, direction_angle, 0.01)
