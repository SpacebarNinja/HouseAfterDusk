extends Button

@export var hover_offset: float = 6.0  # Height when hovered
@export var selected_offset: float = 25.0  # Height when selected
@export var hover_lerp_speed: float = 5.0  # Lerp speed when hovered
@export var selected_lerp_speed: float = 14.0  # Faster lerp when selected
@export var default_lerp_speed: float = 6.0  # Lerp speed when returning to normal

var base_position: Vector2
var target_y_offset: float = 0.0  # Target Y offset
var current_lerp_speed: float = 6.0  # Active lerp speed
var crafting_hud_node
var is_hovering: bool = false  # Tracks if button is hovered

func _ready():
	base_position = position
	crafting_hud_node = get_node("%CraftingHud")

	# Connect signals dynamically
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

func _process(delta):
	if not crafting_hud_node:
		return

	# Get CURRENT_TAB and compare with last character of this button's name
	var CURRENT_TAB = str(crafting_hud_node.CURRENT_TAB)
	var last_char = str(name)[-1]  # Convert name to String before accessing last character

	# Determine target offset and lerp speed
	if CURRENT_TAB == last_char:
		target_y_offset = -selected_offset
		current_lerp_speed = selected_lerp_speed
	elif is_hovering:
		target_y_offset = -hover_offset
		current_lerp_speed = hover_lerp_speed
	else:
		target_y_offset = 0.0
		current_lerp_speed = default_lerp_speed

	# Smooth transition with dynamic lerp speed
	position.y = lerp(position.y, base_position.y + target_y_offset, current_lerp_speed * delta)

func _on_mouse_entered():
	is_hovering = true  # Set hover state to true

func _on_mouse_exited():
	is_hovering = false  # Reset hover state
