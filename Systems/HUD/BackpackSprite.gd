extends Sprite2D

var is_hovering_inventory = false

func _process(_delta):
	var mouse_in_rect = get_rect().has_point(to_local(get_global_mouse_position()))
	
	if mouse_in_rect and Input.is_action_just_pressed("AlternativeMove"):
		is_hovering_inventory = true
	
	if is_hovering_inventory and Input.is_action_just_released("AlternativeMove"):
		is_hovering_inventory = false
