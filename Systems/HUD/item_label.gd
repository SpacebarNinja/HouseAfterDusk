extends Node2D

@onready var label_info = $LabelInfo
@onready var label_description = $LabelDescription

const INFO_OFFSET: Vector2 = Vector2(-50, -70)

func _ready():
	label_info.hide()
	label_description.hide()

func _process(delta):
	global_position = get_global_mouse_position() + INFO_OFFSET

func on_item_mouse_entered(item):
	label_info.show()
	label_description.show()

	var item_name = item.get_property("Name", "")
	var item_description = item.get_property("Description", "")
	var item_type = item.get_property("Type", "")

	label_info.text = "[center][b]" + item_name + "[/b]\n\n[center]  " + item_description + "  [/center]"
	label_description.text = "[center][i]" + item_type + "[/i][/center]"

func on_item_mouse_exited(item):
	if item:
		label_info.hide()
		label_description.hide()
	else:
		print("Error: Expected an Item, but received: ", typeof(item))
