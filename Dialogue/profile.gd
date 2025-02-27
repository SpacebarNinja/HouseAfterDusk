extends TextureRect

@export_enum("Left Side", "Right Side") var position_side: String = "None"

func _ready():
	DialogueManager.got_dialogue.connect(_on_dialogue_spoken)

func _on_dialogue_spoken(line: DialogueLine):
	# If this node is assigned "Left Side" in the inspector,
	# we look at the 'left' tag. Otherwise, we look at the 'right' tag.
	match position_side:
		"Left Side":
			var left_value = line.get_tag_value("left")
			if left_value and left_value != "":
				_apply_texture(left_value)
		"Right Side":
			var right_value = line.get_tag_value("right")
			if right_value and right_value != "":
				_apply_texture(right_value)

func _apply_texture(tag_value: String):
	# Example: "Gene Greyer:Talk" -> [ "Gene Greyer", "Talk" ]
	var parts = tag_value.split(":", false, 2)
	if parts.size() == 2:
		var character_name = parts[0]
		var expression = parts[1]

		# Construct the path to the PNG:
		var image_path = "res://Dialogue/HDSprites/{0}/{0}{1}.png".format([character_name, expression])

		var new_texture = load(image_path)
		if new_texture:
			texture = new_texture
		else:
			print("Failed to load texture at: ", image_path)
	else:
		# If the string isn't split by ":", handle as needed
		print("Tag format should be 'CharacterName:Expression', but got: ", tag_value)
