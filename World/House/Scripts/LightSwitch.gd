extends Node2D

@export var off_sprite: Texture2D
@export var on_sprite: Texture2D
@export var light: Light2D
@export_category("Light Settings")
@export var light_energy = 0.6
@export var light_speed = 3

@onready var switch_on_sfx = $SwitchOnSFX
@onready var switch_off_sfx = $SwitchOffSFX
@onready var sprite_2d = $Sprite2D

var light_state: bool = true
var is_slowly_turning_on: bool = false

func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	pass
	
#====================================

func handle_text():
	if light_state == false:
		WorldManager.Interactables.erase("Switch Off Light")
		WorldManager.add_interactable("Switch On Light", 0, Callable(self, "switch_on"))
	else:
		WorldManager.add_interactable("Switch Off Light", 0, Callable(self, "switch_off"))
		WorldManager.Interactables.erase("Switch On Light")
		
func switch_on():	
	light_state = true
	handle_text()
	sprite_2d.texture = on_sprite
	switch_on_sfx.play()
	if WorldManager.is_generator_on:
		turn_on_light()
	
func switch_off():
	light_state = false
	handle_text()
	sprite_2d.texture = off_sprite
	switch_off_sfx.play()
	if WorldManager.is_generator_on:
		turn_off_light()
	
func turn_on_light() -> void:
	if light_state == true:
		light.energy = light_energy
		light.enabled = true

func turn_off_light() -> void:
	light.energy = 0
	light.enabled = false
	
func _process(delta):
	if is_slowly_turning_on:
		light.energy = lerp(light.energy, light_energy, light_speed * delta)
		
		if abs(light.energy - light_energy) < 0.01:
			light.energy = light_energy
			is_slowly_turning_on = false
	
func slowly_turn_on_light() -> void:
	if light_state == true:
		light.enabled = true
		is_slowly_turning_on = true
