extends EnemyClass

@export_category("Glitch Stats")
@export var glitch_frequency: int = 2
@export var glitch_length: float = 0.2

@export_category("Teleport Stats")
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 4.0

@onready var glitch_timer = $GlitchTimer


var tv_node = null

func _ready():
	tv_node = game_scene.current_map.get_tv_node()
	tv_node.turn_on()
