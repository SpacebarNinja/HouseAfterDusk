extends Sprite2D

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var gene_sprite = $"../AnimatedSprite2D"

func _ready():
	pass

func _process(_delta):
	var item = backpack.get_equipped_item()
	if item:
		var item_image = item.get_property("image", null)
		if item_image:
			texture = load(item_image)
	else:
		texture = null
	
	var move_vector = Input.get_vector("WalkLeft", "WalkRight", "WalkUp", "WalkDown")
	if move_vector.x == -1:
		flip_sprite(true)
	else:
		flip_sprite(false)

func flip_sprite(flip: bool):
	if flip:
		flip_h = true
	else:
		flip_h = false
