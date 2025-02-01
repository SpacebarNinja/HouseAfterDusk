extends Node2D

@export var off_sprite: Texture2D
@export var on_sprite: Texture2D

@onready var power_on_sfx = $PowerOn
@onready var power_off_sfx = $PowerOff
@onready var sprite_2d = $Sprite2D
@onready var electronics = get_tree().get_nodes_in_group("Electronic")

var light_state: bool = true
const TILE_LAYER: int = 2

func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	pass
	
#====================================

func handle_text():
	if WorldManager.is_generator_on == false:
		WorldManager.Interactables.erase("Turn Off Generator")
		WorldManager.add_interactable("Turn On Generator", 2.5, Callable(self, "switch_on"))
	else:
		WorldManager.add_interactable("Turn Off Generator", 2.5, Callable(self, "switch_off"))
		WorldManager.Interactables.erase("Turn On Generator")
		
func switch_on():	
	power_on_sfx.play()
	WorldManager.is_generator_on = true
	flicker_lights()
	handle_text()
	sprite_2d.texture = on_sprite
	
func switch_off():
	power_off_sfx.play()
	WorldManager.is_generator_on = false
	lights_turn_off()
	handle_text()
	sprite_2d.texture = off_sprite

func flicker_lights():
	var delay = [0.2, 0.1, 0.07, 0.3]
	lights_turn_on()
	await get_tree().create_timer(delay[0]).timeout
	lights_turn_off()
	await get_tree().create_timer(delay[1]).timeout
	lights_turn_on()
	await get_tree().create_timer(delay[2]).timeout
	lights_turn_off()
	await get_tree().create_timer(delay[3]).timeout
	for electronic in electronics:
		if electronic.has_method("slowly_turn_on_light"):
			electronic.slowly_turn_on_light()

func lights_turn_on():
	_apply_to_electronics("turn_on_light")

func lights_turn_off():
	_apply_to_electronics("turn_off_light")

func _apply_to_electronics(method: String):
	for electronic in electronics:
		if electronic.has_method(method):
			electronic.call(method)
