extends EnemyClass

#----{ Timers }----
@onready var search_duration: Timer = $SearchDuration
@onready var movement_timer: Timer = $MovementTimer
@onready var window_check: Timer = $WindowCheck
@onready var scream_cooldown: Timer = $ScreamCooldown

var can_scream: bool = true

func _ready():
	super._ready()

func _physics_process(delta: float) -> void:
	handle_vision_cone()
	handle_movement()
	
	if health <= 0:
		Death.emit()

func _on_player_found() -> void:
	current_pathfinding = PATHFINDING.CHASE
	player_seen = true
	player_found_timer.start()
	search_duration.wait_time += 10

func _on_player_lost() -> void:
	current_pathfinding = PATHFINDING.WANDER
	player_seen = false
	statemachine.on_child_transition(statemachine.current_state, "idle")
	
func _on_death():
	statemachine.on_child_transition(statemachine.current_state, "death")
	
func _on_search_duration_timeout() -> void:
	current_pathfinding = PATHFINDING.ORIGIN

func _on_scream_cooldown_timeout() -> void:
	can_scream = true
