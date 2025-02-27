extends Node

@onready var protoset = preload("res://Systems/Inventory/Others/Universal.tres")

var food_items = {}
var berry_list = {"baneberry": 1, "bogberry": 1, "gooseberry": 1}

var crafting_recipes: Dictionary = {
	"bullet": {
		"inputs": {"steel": 1, "Gunpowder": 4},
		"output": 4
	},
	"gun": {
		"inputs": {"gun_barrel": 1, "gun_muzzle": 1, "gun_trigger": 1, "steel": 2},
		"output": 1
	},
	"modified_remote": {
		"inputs": {"chromatic_chip": 1, "monochromatic_chip": 1, "paranormal_chip": 1, "tv_remote": 1},
		"output": 1
	},
	"box_of_chocolates": {
		"inputs": {"chocolate": 1, "red_fabric": 1, "pink_fabric": 1},
		"output": 1
	},
	"plank": {
		"inputs": {"raw_wood": 1},
		"output": 2
	},
	"bolt": {
		"inputs": {"steel": 1},
		"output": 3
	},
	"paranormal_chip": {
		"inputs": {"broken_chip": 1},
		"output": 1
	},
	"makeshift_bat": {
		"inputs": {"plank": 1, "bolt": 2, "stick": 1},
		"output": 1
	},
	"fishing_rod": {
		"inputs": {"stick": 2, "rope": 1},
		"output": 1
	},
	"trap": {
		"inputs": {"plank": 2, "rope": 1, "bolt": 1},
		"output": 1
	},
	"key": {
		"inputs": {"steel": 1, "bolt": 1},
		"output": 1
	},
	"doll_hat": {
		"inputs": {"red_fabric": 1, "pink_fabric": 1},
		"output": 1
	},
	"stick": {
		"inputs": {"plank": 1},
		"output": 2
	},
	"rope": {
		"inputs": {"red_fabric": 1, "pink_fabric": 1},
		"output": 1
	}
}

	
var food_recipes: Dictionary = {
	"barbecue": {
		"inputs": {"meat": 1, "gravy": 1},
		"output": 1
	},
	"berry_salad": {
		"inputs": berry_list,
		"output": 1
	},
	"bread": {
		"inputs": {"flour": 1, "sugar": 1},
		"output": 1
	},
	"chocolate": {
		"inputs": {"cocoa": 1, "sugar": 1},
		"output": 1
	},
	"coffee": {
		"inputs": {"coffee_beans": 1},
		"output": 1
	},
	"cornucopia": {
		"inputs": {"meat": 1, "herb": 1, "grape": 1, "carrot": 1},
		"output": 1
	},
	"crab_meal": {
		"inputs": {"crab": 1, "seaweed": 1},
		"output": 1
	},
	"flour": {
		"inputs": {"rye": 1},
		"output": 1
	},
	"gravy": {
		"inputs": {"flour": 1, "meat": 1, "herb": 1},
		"output": 1
	},
	"grilled_fish": {
		"inputs": {"fish": 1, "pepper": 1, "herb": 1},
		"output": 1
	},
	"grassy_salad": {
		"inputs": {"seaweed": 1, "herbs": 1},
		"output": 1
	},
	"hearty_meal": {
		"inputs": {"meat": 1, "gravy": 1, "mushroom": 1},
		"output": 1
	},
	"jam": {
		"inputs": {"grape": 1, "sugar": 1},
		"output": 1
	},
	"jam_sandwich": {
		"inputs": {"jam": 1, "bread": 1},
		"output": 1
	},
	"pancakes": {
		"inputs": {"flour": 1, "sugar": 1, "grape": 1},
		"output": 1
	},
	"pepper": {
		"inputs": {"black_pepper": 1},
		"output": 1
	},
	"spaghetti": {
		"inputs": {"flour": 1, "mushroom": 1},
		"output": 1
	},
	"sugar": {
		"inputs": {"sugar_cane": 1},
		"output": 1
	},
	"sushi": {
		"inputs": {"octopus": 1, "fish": 1, "pepper": 1, "seaweed": 1},
		"output": 1
	},
	"toxin": {
		"inputs": {"cordyceps": 1},
		"output": 1
	},
	"trash": {
		"inputs": food_items,
		"output": 1
	},
	"veggie_salad": {
		"inputs": {"carrot": 1, "herb": 1, "grape": 1, "mushroom": 1},
		"output": 1
	}}

func _ready():
	for key in food_recipes.keys():
		food_items[key] = 1
	
func get_recipe(recipe: String, dictionary: String) -> Dictionary:
	if dictionary != "Crafting" and dictionary != "Food":
		#print("Error: Invalid dictionary type provided.")
		return {}

	var recipes = crafting_recipes if dictionary == "Crafting" else food_recipes

	# Ensure the recipe exists
	if not recipes.has(recipe):
		#print("Error: Recipe not found for item: ", recipe)
		return {}
		
	# Ensure the recipe exists in the protoset
	if not protoset.has_prototype(recipe):
		#print("Error: Recipe prototype not found for: ", recipe)
		return {}

	var recipe_data = recipes[recipe]
	var inputs = recipe_data["inputs"]
	var output_data = recipe_data["output"]

	var result = {
		"id": recipe,
		"inputs": {},
		"output": output_data
	}

	for input_id in inputs.keys():
		if not protoset.has_prototype(input_id):
			#print("Error: Material prototype not found for: ", input_id)
			continue

		var material = protoset.get_prototype(input_id)
		var material_image = material.get("image", "")
		var material_amount = inputs[input_id]

		result["inputs"][input_id] = {
			"image": material_image,
			"amount": material_amount
		}

	#print("Recipe result: ", result)
	return result

	
func check_food_recipe(materials: Dictionary) -> Dictionary:
	var result = {}

	for recipe_name in food_recipes.keys():
		var recipe = food_recipes[recipe_name]
		var inputs = recipe["inputs"]
		var output = recipe["output"]

		if not keys_match(inputs.keys(), materials.keys()):
			continue

		if all_materials_sufficient(inputs, materials):
			result = {
				"id": recipe_name,
				"inputs": inputs,
				"output": output
			}
			print("Recipe:", recipe_name, " | Can be crafted!")
			return result

	# If no recipe matched, return "trash"
	result = {
		"id": "trash",
		"inputs": materials,
		"output": 1
	}
	print("No recipe can be crafted.")
	return result

func keys_match(recipe_keys: Array, material_keys: Array) -> bool:
	# Create copies of the arrays to avoid modifying the originals
	var sorted_recipe_keys = recipe_keys.duplicate()
	var sorted_material_keys = material_keys.duplicate()

	# Sort both copies
	sorted_recipe_keys.sort()
	sorted_material_keys.sort()

	# Compare the sorted arrays
	return sorted_recipe_keys == sorted_material_keys

func all_materials_sufficient(inputs: Dictionary, materials: Dictionary) -> bool:
	for input_id in inputs.keys():
		if materials.get(input_id, 0) < inputs[input_id]:
			return false
	return true
