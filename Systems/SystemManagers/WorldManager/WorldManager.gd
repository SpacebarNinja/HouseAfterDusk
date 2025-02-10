extends Node

var WorldTime: int = 0  # In-game time from 0 to 2399
var CurrentDay: int = 0
var DisplayTime: String = "12:00 AM"
var DayPart: String = "Night"
var CurrentDate: String = "Day: 0"
var is_generator_on: bool = true
var disable_lights: bool = false

var Interactables: Dictionary = {}
var StopGeneMovement: bool = false

func add_interactable(text: String, intr_duration: float, callback: Callable):
	Interactables[text] = {
		"Text": text,
		"IntrDuration": intr_duration,
		"Callback": callback
	}
