extends Node
class_name AnimationHandler

@export var initial_animation: AnimationBase

var current_animation: AnimationBase
var animations: Dictionary = {}

func _ready():
	for child in get_children():
		if child is Node:
			animations[child.name.to_lower()] = child
			
	if initial_animation:
		current_animation = initial_animation
		current_animation.enter()
		for child in get_children():
			if child != initial_animation:
				child.hide()
	
func _process(delta):
	if current_animation:
		current_animation.update(delta)
		
func _physics_process(delta):
	if current_animation:
		current_animation.physics_Update(delta)

func transition(new_animation_name: String):
	var new_animation = animations.get(new_animation_name.to_lower())
	if !new_animation:
		return
	
	if new_animation:
		new_animation.show()
	
	if current_animation:
		current_animation.exit()
		current_animation.hide()
	# Intialize the new state
	new_animation.enter()
	current_animation = new_animation
