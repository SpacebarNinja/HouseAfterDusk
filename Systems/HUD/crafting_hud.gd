extends CanvasLayer

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var item_display_scene = preload("res://Systems/HUD/craftable_item_display.tscn")
@onready var gear_protoset = preload("res://Systems/Inventory/Others/Gear.tres")
@onready var resource_protoset = preload("res://Systems/Inventory/Others/Resource.tres")
@onready var miscellaneous_protoset = preload("res://Systems/Inventory/Others/Miscellaneous.tres")
@onready var crafting_panel = $CraftingPanel
@onready var item_panel = $ItemPanel

var tabs_dict: Dictionary
var alt_tab_button: Dictionary
var category_dict: Dictionary = {} # Holds categories with their items

enum ITEM_CATEGORY {GEAR, WEAPON, TRAPS, MATERIAL, MISCELANEOUS}
var gear_dict: Dictionary = {}
var trap_dict: Dictionary = {}
var material_dict: Dictionary = {}
var miscelaneous_dict: Dictionary = {}

var currently_crafting: bool

func _ready():
	tabs_dict = {
		"tab1": $CraftingPanel/TabGrid1,
		"tab2": $CraftingPanel/TabGrid2,
		"tab3": $CraftingPanel/TabGrid3,
		"tab4": $CraftingPanel/TabGrid4,
	}
	
	alt_tab_button = {
		"tab1": $CraftingPanel/TabButton1/AltButton1,
		"tab2": $CraftingPanel/TabButton2/AltButton2,
		"tab3": $CraftingPanel/TabButton3/AltButton3,
		"tab4": $CraftingPanel/TabButton4/AltButton4
	}
	
	category_dict = {
		ITEM_CATEGORY.GEAR: gear_dict,
		ITEM_CATEGORY.TRAPS: trap_dict,
		ITEM_CATEGORY.MATERIAL: material_dict,
		ITEM_CATEGORY.MISCELANEOUS: miscelaneous_dict
	}
	show_current_tab("tab1")
	add_item("gun", 1)
	add_item("modified_remote", 1)
	add_item("plank", 1)
	
func _on_tab_button_1_pressed():
	show_current_tab("tab1")

func _on_tab_button_2_pressed():
	show_current_tab("tab2")

func _on_tab_button_3_pressed():
	show_current_tab("tab3")

func _on_tab_button_4_pressed():
	show_current_tab("tab4")

func show_current_tab(current_tab):
	item_panel.hide()
	item_panel.selected_item = ""
	for key in tabs_dict.keys():
		tabs_dict[key].hide()
	for key in alt_tab_button.keys():
		alt_tab_button[key].hide()
	tabs_dict[current_tab].show()
	alt_tab_button[current_tab].show()
	
func add_item(item_id: String, item_count: int):
	var item = null
	if gear_protoset.has_prototype(item_id):
		item = gear_protoset.get_prototype(item_id)
		print("ItemSet: Gear")
	elif resource_protoset.has_prototype(item_id):
		item = resource_protoset.get_prototype(item_id)
		print("ItemSet: Resource")
	elif miscellaneous_protoset.has_prototype(item_id):
		item = miscellaneous_protoset.get_prototype(item_id)
		print("ItemSet: Miscellaneous")
	else:
		print("Could Not add: ", item_id)
		return
		
	var item_name = item["Name"]
	var item_description = item["Description"]
	var item_image = item["image"]
	var item_category = item["Type"]
	
	var new_item = {
		"name": item_name,
		"description": item_description,
		"image": item_image,
		"count": item_count,
		"category": item_category,
		"id": item_id
	}
	# Add the new item to the category dictionary
	#print("NewItem: ", new_item)
	print("Adding Item: ", new_item["name"])
	category_dict[item_category] = new_item
	
	# Instantiate the button for the item and add it to the corresponding tab
	var item_button = create_item_button(new_item)
	match item_category:
		"Weapon", "Tool":
			tabs_dict["tab1"].add_child(item_button)
		"Traps":
			tabs_dict["tab2"].add_child(item_button)
		"Raw Material", "Component":
			tabs_dict["tab3"].add_child(item_button)
		"Entity", "Special":
			tabs_dict["tab4"].add_child(item_button)


# Creates a button for the item
func create_item_button(item: Dictionary):
	var item_display = item_display_scene.instantiate()
	var button = item_display.texture_button

	# Set button properties
	item_display.item_name = item["name"]
	item_display.item_description = item["description"]
	item_display.item_image = item["image"]
	item_display.item_count = item["count"]
	
	#print(item_display, " instantiated with children: ", item_display.get_children())

	button.connect("pressed", Callable(self, "_on_item_selected").bind(item))
	#print(button, " created")

	return item_display

# Handle item selection and display it in the item panel
func _on_item_selected(item: Dictionary):
	# Update the item panel with item details
	var item_id = item["id"]
	
	item_panel.item_name.text = item["name"]
	item_panel.item_description.text = item["description"]
	item_panel.item_display.texture = load(item["image"])
	item_panel.item_count.text = str(item["count"])
	item_panel.selected_item = item_id
	item_panel.display_materials(item_id)
	item_panel.show()
	#print(item, " selected")
