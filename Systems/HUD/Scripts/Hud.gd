extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("Player")

var display_dict: Dictionary
var current_hud: String

func _ready():
	current_display("Main")
	
	display_dict = {
		"Main": $MainHud,
		"Crafting": $CraftingHud,
		"Cooking": $CookingHud,
		"Fishing": $FishingHud,
		"Death": $DeathHud,
		"QTE": $QTEHud
	}

func _input(_event):
	if Input.is_action_pressed("Escape") and not current_hud == "QTE":
		#current_display("Main")
		player.movement_speed = 80
		
func current_display(display):
	for keys in display_dict.keys():
		display_dict[keys].hide()
		display_dict[display].show()
	
	current_hud = display
	if current_hud == "Crafting":
		display_dict["Crafting"].currently_crafting = (current_hud == "Crafting")
		
	elif current_hud == "Fishing":
		display_dict["Fishing"].chance_timer.start()
		display_dict["Fishing"].duration_timer.start()
	
	elif current_hud == "Death":
		display_dict["Death"].animation_player.play("death_screen")
