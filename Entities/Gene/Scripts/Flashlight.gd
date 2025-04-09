extends PointLight2D

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var flashlight_on: bool
var can_toggle: bool = true

func _process(delta: float) -> void:
	var item = backpack.get_equipped_item()

	if item and item.get_property("id", "") == "flashlight":
		can_toggle = true
	else:
		can_toggle = false
		if flashlight_on:
			turn_off_flashlight()  # Only turn off if it's currently on

	if can_toggle and HudManager.flashlight_movement:
		var mouse_position = get_global_mouse_position()
		look_at(mouse_position)
		
func toggle_flashlight():
	if not can_toggle:
		return
	
	if flashlight_on:
		turn_off_flashlight()
	else:
		turn_on_flashlight()
	print("Flashlight ", flashlight_on)

func turn_on_flashlight():
	animation_player.play("turn_on_flashlight")
	flashlight_on = true

func turn_off_flashlight():
	animation_player.play("turn_off_flashlight")
	flashlight_on = false
