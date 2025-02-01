extends Control

var ButtonScene = preload("res://Systems/Journal/Button.tscn")

var current_category_data = {}
var current_category_index = 0
var current_section = ""
var description_categories = []
var behavior_categories = []
var method_categories = []
var description_history = []
var behavior_history = []
var method_history = []

@onready var undo_button = $UndoButton
@onready var submit_button = $SubmitButton
@onready var refresh_button = $RefreshButton
@onready var name_editor = $NameEditor
#-------------------------------------------------
@onready var attitude_button = $AttitudeButton
@onready var attitude_label = $AttitudeLabel
#-------------------------------------------------
@onready var description_button = $DescriptionButton
@onready var description_label = $DescriptionLabel
#-------------------------------------------------
@onready var behavior_label = $BehaviorLabel
@onready var behavior_button = $BehaviorButton
#-------------------------------------------------
@onready var method_label = $MethodOfDispatchLabel
@onready var method_button = $MethodOfDispatchButton
#-------------------------------------------------
@onready var notes_editor = $NotesEditor
@onready var sub_text_label = $SubTextLabel
#-------------------------------------------------
var spawned_buttons = []
var can_edit: bool = false

func _ready():
	initialize_ui()

func initialize_ui():
	attitude_label.hide()
	description_label.hide()
	behavior_label.hide()
	method_label.hide()
	sub_text_label.hide()
	submit_button.hide()
	refresh_button.hide()
	undo_button.hide()

func hide_all_children(node):
	for child in node.get_children():
		child.hide()

func show_all_children(node):
	for child in node.get_children():
		child.show()

func set_can_edit(value: bool):
	can_edit = value

func set_category_data(category_data: Dictionary):
	current_category_data = category_data
	description_categories = category_data["Descriptions"].keys()
	behavior_categories = category_data["Behaviors"].keys()
	method_categories = category_data["Methods"].keys()

#-------------------------------------------------
# ATTITUDE
func _on_attitude_button_pressed():
	if can_edit:
		attitude_label.show()
		current_section = "Attitudes"
		show_all_children(attitude_label)
		hide_all_subcategory_buttons()

func _on_hostile_button_pressed():
	attitude_label.text = 'Attitude: Hostile'
	attitude_label.show()
	hide_all_children(attitude_label)
	show_submit_and_undo_and_refresh_buttons()

func _on_neutral_button_pressed():
	attitude_label.text = 'Attitude: Neutral'
	attitude_label.show()
	hide_all_children(attitude_label)
	show_submit_and_undo_and_refresh_buttons()

func _on_passive_button_pressed():
	attitude_label.text = 'Attitude: Passive'
	attitude_label.show()
	hide_all_children(attitude_label)
	show_submit_and_undo_and_refresh_buttons()

func _on_unpredictable_button_pressed():
	attitude_label.text = 'Attitude: Unpredictable'
	attitude_label.show()
	hide_all_children(attitude_label)
	show_submit_and_undo_and_refresh_buttons()

#-------------------------------------------------
# DESCRIPTION

func _on_description_button_pressed():
	if can_edit:
		description_label.show()
		current_category_index = 0
		current_section = "Descriptions"
		description_history.clear()
		show_next_category_buttons()
		hide_all_subcategory_buttons()
		show_submit_and_undo_and_refresh_buttons()

#-------------------------------------------------
# BEHAVIOR

func _on_behavior_button_pressed():
	if can_edit:
		behavior_label.show()
		current_category_index = 0
		current_section = "Behaviors"
		behavior_history.clear()
		show_next_category_buttons()
		hide_all_subcategory_buttons()
		show_submit_and_undo_and_refresh_buttons()

#-------------------------------------------------
# METHOD

func _on_method_of_dispatch_button_pressed():
	if can_edit:
		method_label.show()
		current_category_index = 0
		current_section = "Methods"
		method_history.clear()
		show_next_category_buttons()
		hide_all_subcategory_buttons()
		show_submit_and_undo_and_refresh_buttons()

#-------------------------------------------------

func show_submit_and_undo_and_refresh_buttons():
	submit_button.show()
	undo_button.show()
	refresh_button.show()

func show_next_category_buttons():
	hide_all_buttons()
	var categories = []
	if current_section == "Descriptions":
		categories = description_categories
	elif current_section == "Behaviors":
		categories = behavior_categories
	elif current_section == "Methods":
		categories = method_categories

	if current_category_index < categories.size():
		var category = categories[current_category_index]
		var y_index = 0
		current_category_data[current_section][category].shuffle()
		var button_count = 0
		var button_limit = 10
		for description in current_category_data[current_section][category]:
			if button_count >= button_limit:
				break
			y_index += 1
			spawn_button(description, y_index, current_category_data[current_section][category].size())
			button_count += 1
		check_buttons_visibility()

func button_press(button):
	if current_section == "Descriptions":
		description_history.append(button.text)
		description_label.text = " ".join(description_history)
		description_button.hide()
	elif current_section == "Behaviors":
		behavior_history.append(button.text)
		behavior_label.text = " ".join(behavior_history)
		behavior_button.hide()
	elif current_section == "Methods":
		method_history.append(button.text)
		method_label.text = " ".join(method_history)
		method_button.hide()

	button.hide()  # Hide the pressed button after it's clicked
	current_category_index += 1

	if current_category_index < get_current_categories().size():
		show_next_category_buttons()
	else:
		hide_all_buttons()
		show_submit_and_undo_and_refresh_buttons()

	hide_all_subcategory_buttons()

func get_current_categories():
	if current_section == "Descriptions":
		return description_categories
	elif current_section == "Behaviors":
		return behavior_categories
	elif current_section == "Methods":
		return method_categories
	return []

func hide_all_buttons():
	for button in spawned_buttons:
		button.hide()

func spawn_button(button_name: String, y: int, total_buttons: int):
	var button_instance = ButtonScene.instantiate()
	var gap_min = 50
	var gap_max = 80
	var x_random = 60
	var rotate_random = 0
	
	var gap = randi_range(gap_min, gap_max)
	var y_starting_point = calculate_starting_point(total_buttons, gap)
	var y_pos = y_starting_point + y * gap
	var x_pos = randi_range(-x_random, x_random)
	button_instance.text = button_name
	button_instance.global_position = Vector2(x_pos, y_pos)
	button_instance.rotation_degrees = randi_range(-rotate_random, rotate_random)
	button_instance.connect("pressed", Callable(self, "button_press").bind(button_instance))
	add_child(button_instance)
	spawned_buttons.append(button_instance)

func calculate_starting_point(total_buttons: int, gap: int) -> int:
	var screen_height = get_viewport_rect().size.y
	var total_height = total_buttons * gap
	return (screen_height - total_height) / 2 - 350

func _on_undo_button_pressed():
	current_category_index = 0
	if current_section == "Descriptions":
		description_history.clear()
		description_label.text = ""
	elif current_section == "Behaviors":
		behavior_history.clear()
		behavior_label.text = ""
	elif current_section == "Methods":
		method_history.clear()
		method_label.text = ""

	show_next_category_buttons()
	check_buttons_visibility()
	show_other_subcategory_buttons()

func _on_submit_button_pressed():
	hide_all_buttons()
	hide_submit_and_undo_and_refresh_buttons()
	show_other_subcategory_buttons()
	queue_free_current_subcategory_button()

func hide_submit_and_undo_and_refresh_buttons():
	submit_button.hide()
	undo_button.hide()
	refresh_button.hide()

func check_buttons_visibility():
	if (current_section == "Descriptions" and description_history.size() == 0) or\
		(current_section == "Behaviors" and behavior_history.size() == 0) or\
		(current_section == "Methods" and method_history.size() == 0):
		undo_button.hide()
	else:
		undo_button.show()

	if current_category_index >= get_current_categories().size():
		show_submit_and_undo_and_refresh_buttons()

func hide_all_subcategory_buttons():
	if is_instance_valid(attitude_button):
		attitude_button.hide()
	if is_instance_valid(description_button):
		description_button.hide()
	if is_instance_valid(behavior_button):
		behavior_button.hide()
	if is_instance_valid(method_button):
		method_button.hide()

func show_other_subcategory_buttons():
	if is_instance_valid(attitude_button):
		attitude_button.show()
	if is_instance_valid(description_button):
		description_button.show()
	if is_instance_valid(behavior_button):
		behavior_button.show()
	if is_instance_valid(method_button):
		method_button.show()

func queue_free_current_subcategory_button():
	if current_section == "Attitudes":
		attitude_button.queue_free()
	if current_section == "Descriptions":
		description_button.queue_free()
	elif current_section == "Behaviors":
		behavior_button.queue_free()
	elif current_section == "Methods":
		method_button.queue_free()

func _on_refresh_button_pressed():
	# Resets the category index and shows the category buttons again
	current_category_index = 0
	show_next_category_buttons()
	check_buttons_visibility()
