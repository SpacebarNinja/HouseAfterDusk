extends Button

@export var opacity_color: Color
@export var lerp_speed: float = 6  # Controls how smooth the transition is
@export var added_hover_y: float

@onready var journal = get_tree().get_first_node_in_group("Journal")
var original_modulate
var original_position
var target_modulate
var target_position
var is_hovering := false


func _ready():
	original_modulate = modulate
	original_position = position
	
	modulate = opacity_color
	target_modulate = opacity_color
	target_position = original_position

func _process(delta):
	modulate = modulate.lerp(target_modulate, lerp_speed * delta)
	position = position.lerp(target_position, lerp_speed * delta)
	
	if !is_hovering:
		if journal.open_journal_state:
			target_modulate = original_modulate
			target_position = original_position + Vector2(0, added_hover_y)
		else:
			target_modulate = opacity_color
			target_position = original_position

func _on_mouse_entered():
	target_modulate = original_modulate
	target_position = original_position + Vector2(0, added_hover_y)
	is_hovering = true
	
func _on_mouse_exited():
	target_modulate = opacity_color
	target_position = original_position
	is_hovering = false
