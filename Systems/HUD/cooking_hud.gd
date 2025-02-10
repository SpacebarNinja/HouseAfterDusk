extends CanvasLayer

# Preload consumable data
@onready var protoset = preload("res://Systems/Inventory/Backpack/Consumables.tres")

# UI Elements
@onready var cooking_panel = $CookingPanel
@onready var cooking_slots = $CookingPanel/CookingSlots
@onready var cooking_grid = $CookingPanel/CookingGrid
@onready var cook_button = $CookingPanel/CookButton

@onready var skill_check = $SkillCheck
@onready var cooking_result = $SkillCheck/CookingResult
@onready var cooking_result_grid = $SkillCheck/CookingResultGrid

@onready var animation_player = $AnimationPlayer

# Constants for better readability
const TYPE_INGREDIENT = "Ingredient"
const CATEGORY_FOOD = "Food"
const ITEM_TRASH = "trash"

# State Variables
var materials_list: Dictionary = {}
var can_craft: bool = false
var is_finished_crafting: bool = true
var craftable_item: String = ""
var craft_amount: int

func _process(delta):
	cook_button.visible = can_craft

func update_food_list(item_id: String, item_count: int, item_type):
	# Update the materials list with the current item
	materials_list[item_id] = item_count
	
	# Remove items with zero or negative count
	if materials_list[item_id] <= 0:
		materials_list.erase(item_id)

	# Re-evaluate can_craft based on the entire materials_list
	if materials_list.is_empty():
		can_craft = false
		
	for material_id in materials_list.keys():
		var item = protoset.get_prototype(material_id)
		if not protoset.has_prototype(material_id) or item.get("Type", "") != TYPE_INGREDIENT:
			can_craft = false
			break  # Exit early if any invalid item is found
		else:
			can_craft = true
			
	# If crafting is allowed, proceed with recipe check
	if is_finished_crafting and can_craft:
		var recipe_check = ItemRecipes.check_food_recipe(materials_list)
		craftable_item = recipe_check.get("id", "")
		craft_amount = calculate_crafting_amount(recipe_check, materials_list)

		if OS.is_debug_build():
			print("RecipeChk: ", recipe_check)
			print("MatList: ", materials_list)
			print("CraftableItem: ", craftable_item)
			print("ItemIsCraftable: ", can_craft)
			print("ItmCnt: ", craft_amount)


func calculate_crafting_amount(recipe, materials):
	var inputs = recipe["inputs"]
	var item = protoset.get_prototype(recipe["id"])
	var max_stack_size = item.get("max_stack_size")

	var craft_times = INF  # Start with a large number to find the minimum possible crafts

	for material_name in inputs.keys():
		if not materials.has(material_name):
			return 0  # Missing material, crafting is impossible

		var required_amount = inputs[material_name]
		var available_amount = materials[material_name]
		var possible_crafts = int(available_amount / required_amount)

		craft_times = min(craft_times, possible_crafts)  # Find the limiting material

	var craft_amount = min(max_stack_size, craft_times)

	return craft_amount

func add_inventory_item(item_id: String, amount: int):
	for i in range(amount):
		cooking_result.create_and_add_item(item_id)

func remove_inventory_item(item_id: String, amount: int):
	var remaining_amount = amount
	for item in cooking_slots.get_children():
		if item.get_property("id", "") == item_id:
			var stack_size = cooking_slots.get_item_stack_size(item)
			if stack_size > remaining_amount:
				cooking_slots.set_item_stack_size(item, stack_size - remaining_amount)
				break
			else:
				cooking_slots.remove_item(item)
				remaining_amount -= stack_size
			if remaining_amount <= 0:
				break

func _on_cooking_item_added(item):
	update_food_list(item.get_property("id", ""), item.get_property("stack_size", ""), item.get_property("Type", ""))

func _on_cooking_item_removed(item):
	update_food_list(item.get_property("id", ""), -1 * item.get_property("stack_size", ""), item.get_property("Type", ""))

func _on_cooking_result_item_removed(item):
	if animation_player:
		animation_player.play_backwards("transition")

func _on_cook_button_pressed():
	if can_craft:
		is_finished_crafting = false
		animation_player.play("transition")
		await animation_player.animation_finished

		var recipe = ItemRecipes.get_recipe(craftable_item, CATEGORY_FOOD)
		var id = recipe["id"]
		var inputs = recipe["inputs"]
		var output = recipe["output"]

		# Deduct materials from inventory
		if id != ITEM_TRASH:
			for material_name in inputs.keys():
				var required_amount = inputs[material_name]["amount"]
				remove_inventory_item(material_name, required_amount * craft_amount)
		else:
			for material_name in materials_list.keys():
				remove_inventory_item(material_name, 1)

		# Add crafted item to inventory
		add_inventory_item(id, output * craft_amount)
		is_finished_crafting = true
	else:
		print("Cannot craft item: Found Non Food Item")
