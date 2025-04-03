extends Node
class_name EnemyStateMachine

@export var initial_state: EnemyState
var current_state: EnemyState

var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is EnemyState:
			states[child.name.to_lower()] = child
			child.transition.connect(on_child_transition)
			
	await get_tree().create_timer(0.2).timeout
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state: EnemyState, new_state_name: String):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
