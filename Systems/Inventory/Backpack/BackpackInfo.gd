extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var protoset = preload("res://Systems/Inventory/Others/Universal.tres")
@onready var item_label = $ItemLabel

@onready var eat = $Eat

@export var inventory: InventoryGridStacked
@export var equippable: InventoryGridStacked

# Hover behavior
var target_position = Vector2()
var target_alpha = 0.6
var hover_speed = 0.2  # The bigger the faster

@onready var select_audio = $SelectAudio
@onready var unselect_audio = $UnselectAudio

func _process(_delta):
	HandleHover()

func HandleHover():
	if get_global_mouse_position().x > 960:
		target_position.x = 1100
		target_alpha = 1.0
	else:
		target_position.x = 1115
		target_alpha = 0.6

	global_position.x = lerp(global_position.x, target_position.x, hover_speed)
	modulate.a = lerp(modulate.a, target_alpha, hover_speed)

func _on_ctrl_inventory_grid_ex_item_mouse_entered(item):
	# Display item info when mouse enters an item
	item_label.on_item_mouse_entered(item)

func _on_ctrl_inventory_grid_ex_item_mouse_exited(item):
	# Hide item info when mouse leaves the item
	item_label.on_item_mouse_exited(item)

func _on_ctrl_inventory_grid_ex_inventory_item_context_activated(item):
	if item.get_property("edible", true) and item.get_property("Type", "") == "Ingredient":
		var food_value = item.get_property("hunger_value")
		remove_inventory_item(item.get_property("id", ""), 1)
		player.replenish_hunger(food_value)
		eat.play()
	else:
		# If not food, attempt to equip or swap
		if item.get_inventory() == inventory:
			if equippable.has_place_for(item):
				item._add_item_to_owner(item, equippable, 0)
			else:
				var item2 = equippable.get_item_at(Vector2i(0,0))
				item.swap(item, item2)

func _on_ctrl_inventory_grid_ex_equippable_inventory_item_context_activated(item):
	if item.get_property("edible", true):
		var food_value = item.get_property("hunger_value")
		remove_equipped_item(item, 1)
		player.replenish_hunger(food_value)
		eat.play()
	else:
		# If not food, attempt to return it to inventory
		if item.get_inventory() == equippable:
			if inventory.has_place_for(item):
				item._add_item_to_owner(item, inventory, 0)
			else:
				print("No Space for Item")

func get_equipped_item():
	var equipped_item = equippable.get_item_at(Vector2i(0,0))
	#print("Equipped Item: ", equipped_item)
	return equipped_item

func add_inventory_item(item: InventoryItem, amount: int):
	if amount <= 0:
		return

	var item_id = item.get_property("id", "")
	var max_stack = item.get_property("max_stack_size", "")

	# Check if there is an existing stack
	var existing_item = inventory.get_item_by_id(item_id) if inventory.has_item_by_id(item_id) else null

	if existing_item:
		var current_stack = inventory.get_item_stack_size(existing_item)
		var available_space = max_stack - current_stack

		# Add to existing stack if possible
		if available_space > 0:
			var amount_to_add = min(amount, available_space)
			inventory.set_item_stack_size(existing_item, current_stack + amount_to_add)
			amount -= amount_to_add

	# If there’s still remaining amount, create a new item
	if amount > 0:
		var new_item = inventory.create_and_add_item(item_id)
		var new_stack_size = min(amount, max_stack)
		inventory.set_item_stack_size(new_item, new_stack_size)

	# Play inventory selection sound if valid
	if is_instance_valid(select_audio) and not select_audio.playing:
		select_audio.play()
		
func remove_inventory_item(item: InventoryItem, amount: int):
	if inventory.has_item(item):
		var stack_size = inventory.get_item_stack_size(item)
		var new_stack_size = stack_size - amount
		inventory.set_item_stack_size(item, new_stack_size)
		#print("Item Stack: ", inventory.get_item_stack_size(item))
		
		if stack_size <= 0:
			inventory.remove_item(item)
			print("Removing ", item)
		else:
			print("Reduced ", item, " stack by ", amount, " and is now ", new_stack_size)

func remove_equipped_item(item, amount):
	var stack_size = equippable.get_item_stack_size(item)
	var new_stack_size = stack_size - amount
	
	equippable.set_item_stack_size(item, new_stack_size)
	#print("Item Stack: ", equippable.get_item_stack_size(item))
	
	if new_stack_size <= 0:
		equippable.remove_item(item)
		print("Removing ", item)

func get_inventory_items() -> Array:
	# Ensure `inventory` is properly set to a node or list of items
	var inventory_items = inventory.get_children()
	var inventory_list = []

	for item in inventory_items:
		var item_id = item.get_property("id", "")
		var stack_size = item.get_property("stack_size", "")

		inventory_list.append({
			"id": item_id,
			"amount": stack_size
		})
	
	return inventory_list

func find_inventory_item(item_id: String):
	if inventory.has_item_by_id(item_id):
		print(item_id, " Found")
		var item = inventory.get_item_by_id(item_id)
		var item_stats = {
			"item": item,
			"position": inventory.get_item_position(item)
		}
		print(item_id, " Stats:", item_stats)
		return item_stats
	else:
		print(item_id, " Not Found")
		return null

func _on_equippable_item_added(item):
	# If a weapon is equipped, notify the player
	if item != null:
		var item_type = item.get_property("Type", "")
		if item_type == "Weapon":
			var item_name = item.get_property("Name", "")
			player.equip_weapon(true, item_name)

func _on_equippable_item_removed(item):
	if is_instance_valid(player) and is_instance_valid(item):
		var item_type = item.get_property("Type", "")
		if item_type == "Weapon":
			var item_name = item.get_property("Name", "")
			player.equip_weapon(false, item_name)
		else:
			print("no Item")

func _on_equippable_contents_changed():
	# Play selection sound
	if is_instance_valid(select_audio) and not select_audio.playing:
		select_audio.play()

func _on_inventory_grid_selection_changed():
	# Play unselection sound
	if is_instance_valid(unselect_audio) and not unselect_audio.playing:
		unselect_audio.play()
