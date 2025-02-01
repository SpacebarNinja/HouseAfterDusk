extends CharacterBody2D
class_name Enemyclass

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var map = get_tree().get_first_node_in_group("Map")
@onready var journal = get_tree().get_first_node_in_group("Journal")

@export_category("Stats")
@export var health: int
@export var movement_speed: int
@export var attack_damage: int
@export var sense: int
@export var intelligence: int

@export_category("Nodes")
@export var navagent: NavigationAgent2D
@export var hit_box: Area2D
@export var vision_cone: Light2D
@export var rotate_vc_timer: Timer
@export var check_vision_timer: Timer
@export var anim_sprite: AnimatedSprite2D
@export var anim_tree: AnimationTree

@export_category("Game")
@export var spawn_location: String
@export var audio: Array[AudioStreamPlayer2D]
@export var state_machine: Node
@export var targets: Dictionary = {
	"doors": false,
	"windows": false,
	"hiding_spots": false,
}

var base_bools: Dictionary = {
	"is_pursuing": false,
	"is_outside": true,
	"is_seen": false,
	"can_move": true,
	"can_play_move_animation": true,
	"player_found": false,
	"directed": false
}

func _ready():
	pass

func _physics_process(_delta):
	pass

func set_target_position(target_position: Vector2) -> void:
	if navagent:
		navagent.target_position = target_position
		
func set_navigation_layer(layer: int, layer_val: bool):
	if navagent:
		navagent.set_navigation_layer_value(layer, layer_val)

func set_can_see(can_see: bool):
	vision_cone.enabled = can_see
	for raycasts in vision_cone.get_children():
		raycasts.set_collision_mask_value(2, can_see)

func set_can_attack(can_atk: bool):
	hit_box.set_collision_mask_value(2, can_atk)

func set_movement_speed(speed: int):
	movement_speed = speed

func set_visibility(visibility: bool):
	set_collision_layer_value(3, visibility)

func play_audio(index: int):
	if index >= 0 and index < audio.size():
		if not audio[index].is_playing():
			audio[index].pitch_scale = randf_range(1.3, 2.5)
			audio[index].play()
	else:
		print("Invalid audio index: ", index)
