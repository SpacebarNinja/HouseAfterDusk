extends Node2D

@export var panel: Panel

<<<<<<< Updated upstream
var window
var area_2d
var min_button
var close_button
=======
@onready var window = $Window
@onready var minimize_button = $Window/Minimize
@onready var close_button = $Window/Close
>>>>>>> Stashed changes

var dragging = false

func _ready():
	window = get_node("Window")
<<<<<<< Updated upstream
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
=======
	minimize_button = get_node("Window/Minimize")
	close_button = get_node("Window/Close")
	
	window.connect("gui_input", Callable(self, "_on_window_gui_input"))
	minimize_button.connect("pressed", Callable(self, "_on_minimize_pressed"))
	close_button.connect("pressed", Callable(self, "_on_close_pressed"))
>>>>>>> Stashed changes

func _on_close_pressed():
	z_index = 0
	hide()

func _on_minimize_toggled(toggled_on):
	if toggled_on:
		panel.hide()
	else:
		panel.show()

func _on_window_gui_input(event):
	var mouse_position = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.is_pressed():
			z_index += 1
		dragging = event.is_pressed()
	elif event is InputEventMouseMotion:
		if dragging:
			global_position = mouse_position 
