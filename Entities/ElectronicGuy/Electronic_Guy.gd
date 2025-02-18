extends CharacterBody2D

@export_category("ElectronicGuy Stats")
@export var glitch_frequency: int = 3
@export var glitch_length: float = 0.2

@export_category("General Enemy Stats")
@export var speed: int = 0
@export var acceleration: int = 7
@export var health: int = -1
@export var attack_damage: int = 100
@export var sense: int = 5
@export var intelligence: int = 4
@export var spawn_location: String

@export_category("Teleport Stats")
@export var teleport_max_speed: int = 100
@export var teleport_min_speed: int = 50
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 10.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var vision_cone = $Vision

var glitch_timer = 0.0
var is_glitching = false
var teleport_timer = 0.0
var is_teleporting = false
var hide_length

func _ready():
	teleport_timer = randi_range(teleport_frequency, round(teleport_frequency/2)) # Reset teleport timer

func _physics_process(delta):
	handle_movement(delta)
	handle_glitch_effect(delta)
	handle_teleport_effect(delta)
	#print('timer: ', teleport_timer)
	#print('teleporting?: ', is_teleporting)
	#print('hide_length: ', hide_length)

func handle_movement(delta):
	var direction = Vector2()
	nav.target_position = player.global_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	handle_vision_cone(direction.angle(), delta)
	move_and_slide()

func handle_vision_cone(direction_angle: float, delta):
	for raycasts in vision_cone.get_children():
		var collider = raycasts.get_collider()
		if collider == player:
			vision_cone.look_at(player.global_position)
		else:
			vision_cone.rotation = lerp_angle(vision_cone.rotation, direction_angle, delta)

func handle_glitch_effect(delta):
	glitch_timer -= delta
	if glitch_timer <= 0 and not is_glitching:
		if randi() % glitch_frequency == 0:
			start_glitch()

func start_glitch():
	is_glitching = true
	anim_sprite.play("Glitch")
	anim_sprite.frame = randi() % 9 + 1  # Random frame from 1 to 9
	glitch_timer = glitch_length
	await get_tree().create_timer(glitch_length).timeout
	end_glitch()

func end_glitch():
	anim_sprite.play("Idle")
	is_glitching = false
	glitch_timer = randi_range(glitch_frequency, round(glitch_frequency/2))

func handle_teleport_effect(delta):
	teleport_timer -= delta
	if teleport_timer <= 0 and not is_teleporting:
		start_teleport()

func start_teleport():
	is_teleporting = true
	speed = randi_range(teleport_min_speed, teleport_max_speed)  # Set random teleport speed
	anim_sprite.play("Teleport") # Play teleport anim then hide
	await anim_sprite.animation_finished
	anim_sprite.hide()
	
	hide_length = randf_range(teleport_min_hide_length, teleport_max_hide_length)
	await get_tree().create_timer(hide_length).timeout
	
	end_teleport()

func end_teleport():
	is_teleporting = false
	teleport_timer = randi_range(teleport_frequency, round(teleport_frequency/2)) # Reset teleport timer
	speed = 0  # Stop movement
	anim_sprite.show() # Show TvG
	anim_sprite.play_backwards("Teleport")
	await anim_sprite.animation_finished
	anim_sprite.play("Idle")
	is_teleporting = false
