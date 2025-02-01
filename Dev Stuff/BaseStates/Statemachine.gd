extends Node

@export var initial_state: Enemy_state

var current_state: Enemy_state
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is Enemy_state:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
			
	if initial_state:
		current_state = initial_state
		current_state.enter()
		
func _process(delta):
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_Update(delta)

func on_child_transition(state: Enemy_state, new_state_name: String):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	# Clean up the previous state
	if current_state:
		current_state.exit()
	
	# Intialize the new state
	new_state.enter()
	current_state = new_state
	print("Current State: ", current_state)
