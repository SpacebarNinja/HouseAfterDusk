extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var mechanic_hud = $MechanicHud

var display_dict: Dictionary
var current_hud: String

func _ready():
	current_display("Main")
	
	display_dict = {
		"Main": $MainHud,
		"Crafting": $CraftingHud,
		"Cooking": $CookingHud,
		"Fishing": $FishingHud
	}


func _input(_event):
	if Input.is_action_pressed("Escape"):
		#current_display("Main")
		player.set_walk_speed(80)
		
func current_display(display):
	for keys in display_dict.keys():
		display_dict[keys].hide()
		display_dict[display].show()
	
	current_hud = display
	if current_hud == "Crafting":
		display_dict["Crafting"].currently_crafting = (current_hud == "Crafting")
		
	if current_hud == "Fishing":
		display_dict["Fishing"].chance_timer.start()
		display_dict["Fishing"].duration_timer.start()

	print("CurrentDisplay: ", display)
