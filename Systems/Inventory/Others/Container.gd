extends Node
class_name Item_Container

enum CONTAINER {CABINET, DRAWER}
enum TYPE {BASIC, UNCOMMON, RARE, FOOD, ENTITY, DEMO}

@export_category("Container Information")
@export var container: CONTAINER
@export var inventory: InventoryGridStacked
@export var type: TYPE

@export var grid_width: int = 2  # Set container width (e.g., 2 for 2x4)
@export var grid_height: int = 2 # Set container height (e.g., 4 for 2x4)

var is_open: bool = false

const LOOT_TABLE_DEMO = {
	"bread": 3, "coffee": 1, "plank": 4, "spring": 3, "bullet": 1, "jam": 2
}

func generate_loot(container_type: TYPE):
	var loot_table = get_loot_table(container_type)
	if loot_table.is_empty():
		return  # No loot available

	var loot_to_add = []

	# Generate grid based on container size
	var all_slots = []
	for x in range(grid_width):
		for y in range(grid_height):
			all_slots.append(Vector2(x, y))  # Populate grid dynamically

	# Determine random slot count (leave some empty)
	var used_slots_count = randi_range(floor(all_slots.size() * 0.5), all_slots.size())  # Use 50-100% slots
	all_slots.shuffle()
	var available_slots = all_slots.slice(0, used_slots_count)

	# Pick random loot
	for item_name in loot_table.keys():
		if randf() < 0.5:  # 50% chance per item
			var max_amount = loot_table[item_name]
			var amount = randi_range(1, max_amount)
			loot_to_add.append({ "name": item_name, "amount": amount })

	# Assign loot to available slots
	for loot in loot_to_add:
		if available_slots.is_empty():
			break  # No more slots left

		var slot = available_slots.pop_front()
		inventory.create_and_add_item_at(loot["name"], slot)

func get_loot_table(container_type: TYPE) -> Dictionary:
	match container_type:
		TYPE.DEMO: return LOOT_TABLE_DEMO
	return {}  # Default empty dictionary
