extends Node2D

@onready var protoset = preload("res://Systems/Inventory/Others/Universal.tres")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")

var crop_list = {
	"goji_berry": {"Coord": Vector2i(1,0), "Matured": Vector2i(5,0), "Growth_time": 300, "Output": 4},
	"acai_berry": {"Coord": Vector2i(1,0), "Matured": Vector2i(6,0), "Growth_time": 300, "Output": 4},
	"goose_berry": {"Coord": Vector2i(1,0), "Matured": Vector2i(7,0), "Growth_time": 300, "Output": 4},
	"nightshade_berry": {"Coord": Vector2i(1,0), "Matured": Vector2i(8,0), "Growth_time": 300, "Output": 2},
	"rye": {"Coord": Vector2i(0,4), "Matured": Vector2i(3,4), "Growth_time": 900, "Output": 3},
	"potato": {"Coord": Vector2i(0,7), "Matured": Vector2i(3,7), "Growth_time": 600, "Output": 3},
	"carrot": {"Coord": Vector2i(0,8), "Matured": Vector2i(3,8), "Growth_time": 600, "Output": 3},
	"grape": {"Coord": Vector2i(0,9), "Matured": Vector2i(3,9), "Growth_time": 600, "Output": 4},
	"coffee_beans": {"Coord": Vector2i(5,10), "Matured": Vector2i(8,10), "Growth_time": 300, "Output": 4},
	"sugarcane": {"Coord": Vector2i(5,7), "Matured": Vector2i(9,0), "Growth_time": 900, "Output": 3}
}

const crop_location = Vector2i(0,-1)

@export_category("Crop Settings")
@export var crop_id: String = "":
	get: return crop_id
	set(new_crop_id):
		if crop_id != new_crop_id:
			crop_id = new_crop_id
@export var age: int = 0:
	get: return age
	set(new_age):
		if age != new_age:
			age = new_age
@export var crop_time: int = 5: #60 = 1 minute| 2400 = 1 day
	get: return crop_time
	set(new_crop_time):
		if crop_time != new_crop_time:
			crop_time = new_crop_time

var crop_tile: TileMapLayer
var growth_timer: Timer
var is_matured: bool = false
var backpack_item

func on_intr_area_entered():
	var crop = backpack.get_equipped_item()
	if crop and crop.get_property("is_crop", true):
		handle_text()
		print("Debug: crop found and is crop")
	elif is_matured == true:
		handle_text()
		print("Debug: crop is mastured")
			
func on_intr_area_exited():
	pass
	
#====================================
func handle_text():
	backpack_item = backpack.get_equipped_item()
	if backpack_item:
		crop_id = backpack_item.get_property("id", "")
		
	if crop_id == "" or not crop_list.has(crop_id):
		print("Invalid crop ID")
		return
		
	if is_matured:
		WorldManager.add_interactable("Harvest Crop", 2, Callable(self, "harvest_crop"))
	else:
		WorldManager.add_interactable("Plant Crop", 2, Callable(self, "plant_crop"))

func _ready():
	crop_tile = get_node("CropLayer")
	growth_timer = get_node("GrowthTimer")

func plant_crop():
	var stack_size = backpack.equippable.get_item_stack_size(backpack_item)
	if stack_size > 0:
		backpack.remove_equipped_item(backpack_item, 1)
		crop_tile.set_cell(crop_location, 0, crop_list[crop_id]["Coord"])
		WorldManager.Interactables.erase("Plant Crop")
		growth_timer.start(crop_time)
		print("Planted: ", crop_id)
		
func grow_plant():
	if not crop_list.has(crop_id):
		print("Invalid crop in grow_plant()")
		return
	
	if is_matured:
		print("Crop Already Matured")
		return
		
	var growth_coord = crop_list[crop_id]["Coord"]
	var matured_coord = crop_list[crop_id]["Matured"]
		 
	growth_timer.start(crop_time)
	if age <= 2:  # Adjusted condition for multi-stage growth
		crop_tile.set_cell(crop_location, 0, Vector2i(growth_coord.x + age, growth_coord.y))
		print(crop_id, " grew and is age: ", age)
	else:
		is_matured = true
		crop_tile.set_cell(crop_location, 0, matured_coord )
		print(crop_id, " is matured and harvestable")

func harvest_crop():
	if not crop_list.has(crop_id):
		print("Invalid crop")
		return

	var crop_output = crop_list[crop_id]["Output"]
	backpack.add_inventory_item(crop_id, crop_output)
	is_matured = false

	match crop_id:
		"goji_berry", "acai_berry", "goose_berry", "nightshade_berry":
			crop_tile.set_cell(crop_location, 0, Vector2i(4, 0))
			age -= 1
			growth_timer.start(crop_time)
			print("Berry Harvested")
		_:
			crop_tile.set_cell(Vector2i(crop_location.x, crop_location.y + 1), 0, Vector2i(1, 6))
			crop_tile.set_cell(Vector2i(crop_location), 0, Vector2i(3, 6))
			age = 0
			print(crop_id, " Harvested")
			
	WorldManager.Interactables.erase("Harvest Crop")
	
func _on_growth_timer_timeout():
	age += 1
	grow_plant()
