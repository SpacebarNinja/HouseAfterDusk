extends Panel

@onready var Backpack = get_tree().get_first_node_in_group("Backpack")

@onready var gear_panel = $GearPanel
@onready var food_panel = $FoodPanel
@onready var material_panel = $ResourcePanel
@onready var enemy_panel = $MiscellaneousPanel

@onready var gear_grid = $GearPanel/Gear
@onready var food_grid = $FoodPanel/Food
@onready var material_grid = $ResourcePanel/Material
@onready var enemy_grid = $MiscellaneousPanel/Enemy

@onready var delay = $Delay
@onready var item_label = $ItemLabel

var item_coord: Vector2i
var current_item
var current_grid

const PANEL_COORD = Vector2(0, 50.4)

func _ready():
	manage_tabs(gear_panel)

func _on_gear_pressed():
	manage_tabs(gear_panel)

func _on_food_pressed():
	manage_tabs(food_panel)
	
func _on_material_pressed():
	manage_tabs(material_panel)
	
func _on_enemy_pressed():
	manage_tabs(enemy_panel)

func manage_tabs(current_tab):
	for panels in get_children():
		if panels is Panel:
			panels.hide()
	
	current_grid = current_tab.get_child(0)
	current_tab.show()
	current_tab.set_position(PANEL_COORD)
	
func on_item_mouse_entered(item):
	item_label.on_item_mouse_entered(item)
	
func on_item_mouse_exited(item):
	item_label.on_item_mouse_exited(item)

func on_item_context_activated(item):
	if Backpack.inventory.has_place_for(item):
		Backpack.add_inventory_item(item.get_property("id",""), 1)
	
func on_item_removed(item):
	if item and is_instance_valid(item) and is_instance_valid(current_grid):
		item_coord = current_grid.get_item_position(item)
		current_item = item.get_property("id", "")
		
		if is_instance_valid(delay) and delay.is_inside_tree():
			delay.start()

func _on_delay_timeout():
	current_grid.create_and_add_item_at(current_item, item_coord)
