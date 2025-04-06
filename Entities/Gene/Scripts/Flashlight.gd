extends PointLight2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var flashlight_on: bool
var can_toggle: bool = true

func _process(delta: float) -> void:
	if HudManager.flashlight_movement:
		var mouse_position = get_global_mouse_position()
		look_at(mouse_position)
		
func toggle_flashlight():
	flashlight_on = not flashlight_on
	
	if not can_toggle:
		return
	
	if flashlight_on:
		turn_on_flashlight()
	else:
		turn_off_flashlight()
	print("Flashlight ", flashlight_on)

func turn_on_flashlight():
	animation_player.play("turn_on_flashlight")
	
func turn_off_flashlight():
	animation_player.play("turn_off_flashlight")
