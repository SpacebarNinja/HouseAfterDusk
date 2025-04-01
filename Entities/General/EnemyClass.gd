extends Node
class_name EnemyClass

@onready var qte_hud = get_tree().get_first_node_in_group("QTEHud")
@onready var game_scene = get_tree().get_first_node_in_group("GameScene")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var item_drop = preload("res://Systems/Inventory/Others/dropped_item.tscn")

@export_category("General Enemy Stats")
@export var movement_speed: int = 75
@export var health: int = 100
@export var attack_damage: int = 0
@export var suspicion: float = 0

@export_category("Other Stats")
@export var origin_location: Vector2
@export var spawn_location: String

@export_category("General Enemy Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var anim_player: AnimationPlayer
@export var anim_tree: AnimationTree
@export var navigation_agent: NavigationAgent2D
@export var vision_cone: PointLight2D
@export var hitbox: Area2D
