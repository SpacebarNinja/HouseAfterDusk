extends CanvasLayer

@export_category("Crafting")
@export var move_offset: float = -50.0
@export var move_speed: float = 5.0
var camera_anchor = Vector2.ZERO

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var item_display_scene = preload("res://Systems/HUD/WorkbenchSystem/craftable_item_display.tscn")
@onready var protoset = preload("res://Systems/Inventory/Others/Universal.tres")
@onready var scroll_base = $Table/ScrollBase
@onready var item_panel = $Table/ScrollBase/ItemPanel
@onready var table = $Table
@onready var scroll_container1 = $Table/ScrollBase/ScrollContainer1

var tabs_dict: Dictionary
var CURRENT_TAB = 0

var currently_crafting: bool

func _ready():
	scroll_container1.get_v_scroll_bar().custom_minimum_size.x = 55;
	
	tabs_dict = {
		"tab1": $Table/ScrollBase/ScrollContainer1/TabGrid1,
		"tab2": $Table/ScrollBase/ScrollContainer2/TabGrid2,
		"tab3": $Table/ScrollBase/ScrollContainer3/TabGrid3,
		"tab4": $Table/ScrollBase/ScrollContainer4/TabGrid4,
	}

	show_current_tab("tab1")
	CURRENT_TAB = 1
	
	load_everything()
	
func _process(delta):
	if HudManager.is_crafting:
		HudManager.camera_movement = false
		HudManager.flashlight_movement = false
		
	HandleTableOffset(delta)

func load_everything():
	for item_id in ItemRecipes.crafting_recipes.keys():
		var output_count = ItemRecipes.crafting_recipes[item_id]["output"]
		add_item(item_id, output_count)

func _on_tab_button_1_pressed():
	show_current_tab("tab1")
	CURRENT_TAB = 1
	#scroll_base.position = scroll_base.closed_position

func _on_tab_button_2_pressed():
	show_current_tab("tab2")
	CURRENT_TAB = 2
	#scroll_base.position = scroll_base.closed_position
	
func _on_tab_button_3_pressed():
	show_current_tab("tab3")
	CURRENT_TAB = 3
	#scroll_base.position = scroll_base.closed_position
	
func _on_tab_button_4_pressed():
	show_current_tab("tab4")
	CURRENT_TAB = 4
	#scroll_base.position = scroll_base.closed_position
	
func show_current_tab(current_tab):
	item_panel.hide()
	item_panel.selected_item = ""
	for key in tabs_dict.keys():
		tabs_dict[key].hide()
	tabs_dict[current_tab].show()
	
func add_item(item_id: String, item_count: int):
	# Prepare the new item
	if not protoset.has_prototype(item_id):
		return
		
	var item = protoset.get_prototype(item_id)
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
	
	# Instantiate the button for the item and add it to the corresponding tab
	var item_button = create_item_button(new_item)
	match item_category:
		"Tool", "Weapon":
			tabs_dict["tab1"].add_child(item_button)
		"Raw Material":
			tabs_dict["tab2"].add_child(item_button)
		"Component":
			tabs_dict["tab3"].add_child(item_button)
		"Entity", "Special":
			tabs_dict["tab4"].add_child(item_button)
	print("New Button: ", item_button, " in ", item_category)
	
# Creates a button for the item
func create_item_button(item: Dictionary):
	var item_display = item_display_scene.instantiate()
	var button = item_display.texture_button

	# Set button properties
	item_display.item_name = item["name"]
	item_display.item_description = item["description"]
	item_display.item_image = item["image"]
	item_display.item_count = item["count"]
	item_display.item_id = item["id"]
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
	item_panel.item_count.text = str(item["count"]) + "x"
	item_panel.selected_item = item_id
	item_panel.display_materials(item_id)
	item_panel.show()
	#print(item, " selected")

func HandleTableOffset(delta):
	var target_x = (move_offset if HudManager.is_crafting else 0.0)
	offset.x = lerp(offset.x, target_x, move_speed * delta)
