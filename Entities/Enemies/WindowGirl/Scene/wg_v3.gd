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
	handle_vision_cone_detection()
	handle_vision_cone_rotation(delta)
	handle_movement()
	
	if health <= 0:
		Death.emit()

func _on_player_found() -> void:
	current_pathfinding = PATHFINDING.CHASE
	player_seen = true
	player_found_timer.start()
	search_duration.wait_time += 10
	
	if can_scream:
		statemachine.on_child_transition(statemachine.current_state, "scream")

func _on_player_lost() -> void:
	current_pathfinding = PATHFINDING.WANDER
	movement_speed = 75
	player_seen = false
	statemachine.on_child_transition(statemachine.current_state, "roam")
	
func _on_death():
	statemachine.on_child_transition(statemachine.current_state, "death")
	
func _on_search_duration_timeout() -> void:
	current_pathfinding = PATHFINDING.ORIGIN

func _on_scream_cooldown_timeout() -> void:
	can_scream = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area == player.hitbox:
		player_in_hitbox = true
		print("player in hitbox A")

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area == player.hitbox:
		player_in_hitbox = false
		print("player out of hitbox A")
