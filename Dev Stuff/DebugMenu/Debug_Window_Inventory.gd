extends Panel

@onready var Gear_Items = $GearPanel
@onready var Food_Items = $FoodPanel
@onready var Material_Items = $ResourcePanel
@onready var Enemy_Items = $MiscellaneousPanel

@onready var gear_grid = $GearPanel/Gear
@onready var food_grid = $FoodPanel/Food
@onready var material_grid = $ResourcePanel/Material
@onready var enemy_grid = $MiscellaneousPanel/Enemy

@onready var gear_grids = $GearPanel/GearGrid

@onready var item_label = $ItemLabel
var item_location

const PANEL_COORD = Vector2(0, 50.4)

func _ready():
	manage_tabs("Gear")

func _on_gear_pressed():
	manage_tabs("Gear")

func _on_food_pressed():
	manage_tabs("Food")
	
func _on_material_pressed():
	manage_tabs("Material")
	
func _on_enemy_pressed():
	manage_tabs("Enemy")

	
func manage_tabs(current_tab):
	for panels in get_children():
		if panels is Panel:
			panels.hide()
	
	match current_tab:
		"Gear":
			Gear_Items.show()
			Gear_Items.set_position(PANEL_COORD)
		"Food":
			Food_Items.show()
			Food_Items.set_position(PANEL_COORD)
		"Material":
			Material_Items.show()
			Material_Items.set_position(PANEL_COORD)
		"Enemy":
			Enemy_Items.show()
			Enemy_Items.set_position(PANEL_COORD)

func on_item_mouse_entered(item):
	item_label.on_item_mouse_entered(item)
	
func on_item_mouse_exited(item):
	item_label.on_item_mouse_exited(item)
<<<<<<< Updated upstream
=======

func on_item_context_activated(item):
	if Backpack.inventory.has_place_for(item):
		Backpack.add_inventory_item(item, 1)
	
func on_item_removed(item):
	if item and is_instance_valid(item) and is_instance_valid(current_grid):
		item_coord = current_grid.get_item_position(item)
		current_item = item.get_property("id", "")
		
		if is_instance_valid(delay) and delay.is_inside_tree():
			delay.start()

func _on_delay_timeout():
	current_grid.create_and_add_item_at(current_item, item_coord)
>>>>>>> Stashed changes
