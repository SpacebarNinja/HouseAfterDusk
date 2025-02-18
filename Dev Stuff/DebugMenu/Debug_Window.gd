extends Node2D

@export var panel: Panel

var window
var area_2d
var min_button
var close_button

var mouse_in = false
var dragging = false

func _ready():
	window = get_node("Window")
	area_2d = get_node("Window/Area2D")
	min_button = get_node("Window/Minimize")
	close_button = get_node("Window/Close")
	
	min_button.connect("toggled", Callable(self, "_on_minimize_toggled"))
	close_button.connect("pressed", Callable(self, "_on_close_pressed"))
	area_2d.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area_2d.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
func _input(event):
	var mouse_position = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.is_pressed() and mouse_in:
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			global_position = mouse_position
			

func _on_mouse_entered():
	mouse_in = true

func _on_mouse_exited():
	mouse_in = false

func _on_close_pressed():
	hide()

func _on_minimize_toggled(toggled_on):
	if toggled_on:
		panel.hide()
	else:
		panel.show()
