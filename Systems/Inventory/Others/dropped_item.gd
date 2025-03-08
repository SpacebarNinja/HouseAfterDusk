extends Node2D

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var dropped_item = $DroppedItem

@export var id: String
@export var amount: int
var item = null

func _ready():
	item = GlobalItemList.get_item_by_id(id)
	
	dropped_item.create_and_add_item(id)
	dropped_item.set_item_stack_size(item, amount)

func on_intr_area_entered():
	handle_text()

func on_intr_area_exited():
	pass
	
#====================================

func handle_text():
	WorldManager.add_interactable(str("Pickup ", id), 0, Callable(self, "pickup_item"))
	
func pickup_item():
	backpack.add_inventory_item(item, amount)
	queue_free()

func _on_despawn_timer_timeout():
	queue_free()
