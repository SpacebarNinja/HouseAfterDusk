extends Node2D

@export var panel: Panel

@onready var window = $Window
@onready var area_2d = $Window/Area2D
@onready var minimize_button = $Window/Minimize
@onready var close_button = $Window/Close

var mouse_in = false
var dragging = false
var minimized: bool = false

signal minimizing_window

func _ready():
	window = get_node("Window")
	area_2d = get_node("Window/Area2D")
	minimize_button = get_node("Window/Minimize")
	close_button = get_node("Window/Close")
	
	minimize_button.connect("pressed", Callable(self, "_on_minimize_pressed"))
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

func _on_minimize_pressed():
	minimized = not minimized
	
	if minimized:
		panel.hide()
		minimizing_window.emit()
	else:
		panel.show()
