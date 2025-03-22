extends Node2D

@onready var label_info = %LabelInfo
@onready var label_description = %LabelDescription
@onready var margin_container = $MarginContainer

var general_offset: Vector2 = Vector2(15.0, 0)
var hover_offset: Vector2 = Vector2(10.0, 0.0)
var target_offset: Vector2 = Vector2(0.0, 0.0)
var mouse_hovered: bool = false
var hover_speed = 10
var target_alpha: float = 0.0
var opaque_speed: float

func _ready():
	visible = true
	target_offset = Vector2(0.0, 0.0)
	self_modulate.a = target_alpha
	
	opaque_speed = 10.0

func _process(delta):
	var tooltip_size = margin_container.size / 10.22
	var mouse_pos = get_global_mouse_position()
	
	global_position.x = mouse_pos.x - tooltip_size.x + target_offset.x + general_offset.x
	global_position.y = mouse_pos.y - 30 + target_offset.y + general_offset.y
	
	# Smoothly lerp target_offset and alpha value
	target_offset = target_offset.lerp(Vector2(0.0, 0.0), delta * hover_speed)
	modulate.a = lerp(modulate.a, target_alpha, delta * opaque_speed)

func on_item_mouse_entered(item):
	var item_name = item.get_property("Name", "")
	var item_description = item.get_property("Description", "")
	var item_type = item.get_property("Type", "")

	label_info.text = "[center][b]" + item_name + "[/b]\n\n[center]  \"" + item_description + ".\"  [/center]"
	label_description.text = "\n[center][i]" + item_type + "[/i][/center]"
	
	target_offset = hover_offset
	target_alpha = 1.0  # Fully visible
	opaque_speed = 10.0

func on_item_mouse_exited(item):
	target_offset = Vector2(0.0, 0.0)
	target_alpha = 0.0  # Fully transparent
	opaque_speed = 20.0
