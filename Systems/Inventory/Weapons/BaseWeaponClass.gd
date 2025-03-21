extends Node2D
class_name BaseWeapon

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")

enum WEAPON_TYPE {RANGE, MELEE}

@export_category("Weapon Stats")
@export var damage: int = 20
@export var attack_speed: float = 1.0
@export var weapon_type: WEAPON_TYPE

@export_category("Weapon Nodes")
@export var animation_tree: AnimationTree

var can_attack: bool = true

func start_attack_cooldown():
	can_attack = false  # Prevent further attacks
	var temp_timer = Timer.new()  # Create a new Timer instance
	temp_timer.wait_time = attack_speed  # Set cooldown duration
	temp_timer.one_shot = true  # Ensure it only runs once
	temp_timer.timeout.connect(_on_attack_cooldown_timeout)  # Connect the timeout signal
	add_child(temp_timer)  # Add it to the weapon
	temp_timer.start()  # Start the timer

func _on_attack_cooldown_timeout():
	can_attack = true  # Allow attacking again
