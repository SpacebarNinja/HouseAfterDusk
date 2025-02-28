extends TextureRect

@onready var label = $Label

@export_category("Window Settings")
@export var panel: Panel

var dragging = false
var minimized: bool = false

func _on_close_pressed():
	hide()

func _on_minimize_pressed():
	minimized = not minimized
	
	if minimized:
		panel.hide()
	else:
		panel.show()

func _on_gui_input(event):
	var mouse_position = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.is_pressed():
			dragging = true
			#print("Selected window")
		else:
			dragging = false
			#print("Not selected window")
	elif event is InputEventMouseMotion:
		if dragging:
			global_position = mouse_position - (size/2)
			#print("Dragging window")

func _on_label_text_submitted(_new_text):
	label.set_editable(false)
	label.set_selecting_enabled(false)
	label.set_mouse_filter(Control.MOUSE_FILTER_PASS)
