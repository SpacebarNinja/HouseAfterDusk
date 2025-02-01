extends Control

@onready var item_label = $TextureButton/Label
@export var texture_button: TextureButton

var item_name: String
var item_description: String
var item_image: String
var item_count: int

func _ready():
	if item_image != "":
		var texture = load(item_image)
		if texture:
			texture_button.set_texture_normal(texture)
	if item_count > 1:
		item_label.text = str(item_count)
	else:
		item_label.hide()
