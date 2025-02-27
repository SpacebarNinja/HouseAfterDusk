extends Node

## ----------------------------------------------
## HUD MANAGER
## ----------------------------------------------

var clock_visible = true
var journal_visible = true
var stats_visible = true
var inventory_visible = true

var flashlight_movement = true
var camera_movement = true
var interaction_enabled = true

var is_crafting = false

var is_dialoguing = false

func _ready():
	pass

func _process(_delta):
	var balloon = get_node_or_null("/root/MainScene/DialogueBox")
	is_dialoguing = balloon != null
