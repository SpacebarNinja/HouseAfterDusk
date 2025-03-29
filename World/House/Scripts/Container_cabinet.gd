extends Item_Container

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var item_label: Node2D = $ItemLabel

const open_coord = Vector2i(10,5)
const close_coord = Vector2i(7,5)

@export var tilemaplayer: TileMapLayer
@export var tilemap_coord: Vector2i

func _ready():
	self.visible = false
	generate_loot(TYPE.DEMO)
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("Escape") and is_open:
		close_container()
	
func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	close_container()
	
#====================================

func handle_text():
	if is_open:
		WorldManager.add_interactable(str("Close Container"), 0, Callable(self, "close_container"))
		WorldManager.Interactables.erase("Open Container")
	else:
		WorldManager.add_interactable(str("Open Container"), 0, Callable(self, "open_container"))
		WorldManager.Interactables.erase("Close Container")

func open_container():
	tilemaplayer.set_cell(tilemap_coord, 0, open_coord)
	is_open = true
	self.visible = true
	handle_text()
	
func close_container():
	tilemaplayer.set_cell(tilemap_coord, 0, close_coord)
	is_open = false
	self.visible = false
	handle_text()
	
func _on_ctrl_inventory_grid_ex_inventory_item_context_activated(item):
	if backpack.inventory.has_place_for(item):
		item._add_item_to_owner(item, backpack.inventory, 0)

func _on_ctrl_inventory_grid_ex_item_mouse_entered(item):
	item_label.on_item_mouse_entered(item)

func _on_ctrl_inventory_grid_ex_item_mouse_exited(item):
	item_label.on_item_mouse_exited(item)
