extends Label

var target_scale: Vector2 = Vector2(1.0, 1.0)  # Scale, not size
var lerp_speed: float = 15.0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP  
	custom_minimum_size = get_minimum_size()

func _process(delta):
	scale = scale.lerp(target_scale, lerp_speed * delta)  # ✅ Use scale instead of size

	var mouse_pos = get_global_mouse_position()
	var label_rect = Rect2(global_position, size)

	if label_rect.has_point(mouse_pos):
		target_scale = Vector2(1.2, 1.2)
	else:
		target_scale = Vector2(1.0, 1.0)
