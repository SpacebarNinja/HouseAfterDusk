extends Control

@export var texture_button: TextureButton
@export var normal_color: Color = Color(1, 1, 1)
@export var hover_color: Color = Color(0.8, 0.8, 0.8)
@export var unavailable_color: Color = Color(0.5, 0.5, 0.5)  # Darker color when not craftable

@export var brightness_factor_craftable: float = 1.3   # Brightness when craftable
@export var brightness_factor_uncraftable: float = 0.5 # Dimmer when not craftable
@export var yellow_tint: Color = Color(3, 1.1, 0.4, 1)  # Yellow hue for selection

@onready var item_label = $TextureButton/Label
@onready var texture_rect = $TextureButton/TextureRect
@onready var click_sfx = $ClickSFX

var item_name: String
var item_description: String
var item_image: String
var item_count: int
var item_id: String  # Added to track the item ID for craftability checks

@export_category("Hover")
@export var hover_scale = 0.95
@export var hover_speed = 5.0
@export var selected_scale = 1.0
@export var selected_speed = 25.0

var target_scale: float = 1.0
var is_selected: bool = false
var is_craftable: bool = true  # Track craftability status

static var currently_selected_button: Control = null

@onready var backpack = get_tree().get_first_node_in_group("Backpack")  # Reference to backpack

func _ready():
	if item_image != "":
		var texture = load(item_image)
		if texture:
			texture_button.set_texture_normal(texture)
	if item_count > 1:
		item_label.text = str(item_count)
	else:
		item_label.hide()

	texture_button.mouse_entered.connect(_on_mouse_entered)
	texture_button.mouse_exited.connect(_on_mouse_exited)
	texture_button.pressed.connect(_on_button_pressed)

	target_scale = 0.9

func _process(delta):
	var lerp_speed = selected_speed if is_selected else hover_speed
	scale = scale.lerp(Vector2(target_scale, target_scale), lerp_speed * delta)

	# Update craftability live
	update_craftability()

func update_craftability():
	if item_id == "":
		return  # Skip if item ID is not set

	var recipe = ItemRecipes.get_recipe(item_id, "Crafting")
	if recipe.is_empty():
		return  # No recipe, skip

	is_craftable = check_craftability(recipe)  # Update craftability status

	# Apply base color based on craftability
	var base_color = normal_color if is_craftable else unavailable_color
	var brightness = brightness_factor_craftable if is_craftable else brightness_factor_uncraftable

	# Apply selection effects if selected
	if is_selected:
		var bright_yellow = (base_color * brightness).lerp(yellow_tint, 0.5)
		texture_button.modulate = bright_yellow
	else:
		texture_button.modulate = base_color * brightness

func check_craftability(recipe: Dictionary) -> bool:
	var inventory_items = backpack.get_inventory_items()
	for material_name in recipe["inputs"].keys():
		var required_amount = recipe["inputs"][material_name]["amount"]
		var has_material = false

		for inv_item in inventory_items:
			if inv_item["id"] == material_name and inv_item["amount"] >= required_amount:
				has_material = true
				break

		if not has_material:
			return false  # Missing materials

	return true  # All materials available

func _on_mouse_entered():
	if not is_selected:
		target_scale = hover_scale
		texture_button.modulate = hover_color

func _on_mouse_exited():
	if not is_selected:
		target_scale = 0.9
		# Ensure craftability status is shown on mouse exit
		var brightness = brightness_factor_craftable if is_craftable else brightness_factor_uncraftable
		texture_button.modulate = (normal_color if is_craftable else unavailable_color) * brightness

func _on_button_pressed():
	click_sfx.play()

	# Deselect the previously selected button if it's different from this one
	if currently_selected_button and currently_selected_button != self:
		currently_selected_button.deselect()

	# Select this button if it's not already selected
	if not is_selected:
		is_selected = true
		currently_selected_button = self
		target_scale = selected_scale

		# Apply selection effect immediately
		update_craftability()

func deselect():
	is_selected = false
	target_scale = 0.9
	# Reset to current craftability color after deselection
	var brightness = brightness_factor_craftable if is_craftable else brightness_factor_uncraftable
	texture_button.modulate = (normal_color if is_craftable else unavailable_color) * brightness
