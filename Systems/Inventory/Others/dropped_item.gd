extends Node2D

@onready var dropped_item = $DroppedItem
@export var id: String
@export var amount: int

func _ready():
	var item = dropped_item.get_item_by_id(id)
	
	dropped_item.add_item(item)
	dropped_item.set_item_stack_size(amount)
