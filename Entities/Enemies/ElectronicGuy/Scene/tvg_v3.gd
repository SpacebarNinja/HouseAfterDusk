extends EnemyClass

@export_category("Glitch Stats")
@export var glitch_frequency: int = 2
@export var glitch_length: float = 0.2

@export_category("Teleport Stats")
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 4.0

#----{ Timers }----
@onready var search_duration: Timer = $SearchDuration
@onready var prowl_timer: Timer = $ProwlTimer
@onready var glitch_timer: Timer = $GlitchTimer
@onready var movement_timer: Timer = $MovementTimer
@onready var teleport_duration = $TeleportDuration

var tv_node = null

func _ready():
	super._ready()
	toggle_vision(false)
	toggle_hitbox(false)
	tv_node = game_scene.current_map.get_tv_node()
	tv_node.turn_on()

func _physics_process(delta: float) -> void:
	handle_vision_cone_detection()
	handle_vision_cone_rotation(delta)
	handle_movement()
	
func terminate() -> void:
	print("Turned Off Generator, Killing TvG")
	queue_free()

func _on_player_found() -> void:
	current_pathfinding = PATHFINDING.CHASE
	player_seen = true
	player_found_timer.start()
	search_duration.wait_time += 10

func _on_player_lost() -> void:
	current_pathfinding = PATHFINDING.WANDER
	player_seen = false

func _on_search_duration_timeout() -> void:
	current_pathfinding = PATHFINDING.ORIGIN
