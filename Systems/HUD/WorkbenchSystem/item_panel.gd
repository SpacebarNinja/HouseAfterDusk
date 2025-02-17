extends Control

@export var fade_in_speed: float = 7.0
@export var cannot_craft_color: Color = Color(2, 0, 0)
@export var can_craft_color: Color = Color(0, 0.6, 0)

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var item_description = $ItemDescription
@onready var item_display = $ItemDisplay
@onready var item_name = $HBoxContainer/ItemName
@onready var item_count = $HBoxContainer/ItemCount
@onready var item_label = $ItemLabel
@onready var materials_display = $MaterialDisplay
@onready var crafting_hud = get_parent()
@onready var can_craft = $CanCraft
@onready var craft_sfx = $"../../../CraftSFX"

var materials_requirements: Array = []  # Initialize as an empty array
var selected_item = ""  # Default to an empty string
var item_craftable = false  # Default crafting state
var original_position: Vector2

func _ready():
	hide()
	materials_requirements = materials_display.get_children()  # Initialize requirements array
	original_position = position
	
func _process(delta):
	modulate.a = lerp(modulate.a, 1.0, fade_in_speed * delta)
	position.x = lerp(position.x, original_position.x, fade_in_speed * delta)
	
func display_materials(item: String):
	modulate.a = 0.0
	position.x = original_position.x - 15
	
	selected_item = item
	var recipe = ItemRecipes.get_recipe(item, "Crafting")
	if recipe.is_empty():
		print("No recipe found for item:", item)
		return  # No recipe data for the item

	# Display each material's image and amount
	var input_materials = recipe["inputs"]
	for i in range(materials_requirements.size()):
		if i < input_materials.keys().size():
			var material_name = input_materials.keys()[i]
			var material_data = input_materials[material_name]
			var material_image = material_data["image"]
			var material_amount = material_data["amount"]

			# Update material display if nodes exist
			var count_node = materials_requirements[i].get_node("ItemCount") if materials_requirements[i].has_node("ItemCount") else null

			materials_requirements[i].texture = load(material_image)
			if count_node:
				count_node.text = str(material_amount)
		else:
			# Hide unused material slots
			materials_requirements[i].texture = null
			var count_node = materials_requirements[i].get_node("ItemCount") if materials_requirements[i].has_node("ItemCount") else null
			if count_node:
				count_node.text = ""

	# Check craftability after updating display
	check_inventory_items(recipe)

func check_inventory_items(recipe):
	var inventory_items = backpack.get_inventory_items()
	item_craftable = true  # Start assuming craftable

	for material_name in recipe["inputs"].keys():
		var required_amount = recipe["inputs"][material_name]["amount"]
		var has_material = false

		for inv_item in inventory_items:
			if inv_item["id"] == material_name and inv_item["amount"] >= required_amount:
				has_material = true
				break

		if not has_material:
			item_craftable = false
			break

	# Update the crafting status label
	update_crafting_status()

func update_crafting_status():
	if item_craftable:
		can_craft.text = "[b]You have enough materials to craft this item.[/b]"
		can_craft.modulate = can_craft_color
	else:
		can_craft.text = "[b]You don't have enough materials to craft this item.[/b]"
		can_craft.modulate = cannot_craft_color

func _on_craft_button_pressed():
	if item_craftable:
		print("Crafting Item: ", selected_item)
		var recipe = ItemRecipes.get_recipe(selected_item, "Crafting")
		var id = recipe["id"]
		var inputs = recipe["inputs"]
		var output = recipe["output"]

		# Deduct materials from inventory
		for material_name in inputs.keys():
			var material_data = inputs[material_name]
			var required_amount = material_data["amount"]
			backpack.remove_inventory_item(backpack.inventory.get_item_by_id(material_name), required_amount)

		# Add crafted item to inventory
		print("Selected Item: ", backpack.inventory.get_item_by_id(selected_item))
		backpack.add_inventory_item(backpack.inventory.get_item_by_id(selected_item), output)
		display_materials(selected_item)
		
		craft_sfx.play()
		
	else:
		print("Cannot craft item: insufficient materials.")
