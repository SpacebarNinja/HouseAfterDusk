extends TextureRect

@export var move_speed: float = 5.0
@export var move_offset: float = 100.0

var closed_position: Vector2
var open_position: Vector2
var target_position: Vector2

func _ready():
	open_position = position
	closed_position = position + Vector2(move_offset, 0)
	position = closed_position
	target_position = closed_position

func _process(delta):
	# Smoothly move towards the target
	position = lerp(position, target_position, move_speed * delta)
		
	if HudManager.is_crafting:
		target_position = open_position
	else:
		target_position = closed_position

func _input(event):
	if HudManager.is_crafting and event.is_action_pressed("Escape"):
		HudManager.is_crafting = false
		WorldManager.StopGeneMovement = false
