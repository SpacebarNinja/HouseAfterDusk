extends Control

@onready var main_scene = get_tree().get_first_node_in_group("GameScene")
@onready var death_stats = $DeathStats

@onready var general_information: Label = $DeathStats/GeneralInformation
@onready var statistics: RichTextLabel = $DeathStats/Statistics
@onready var flavor_text: Label = $DeathStats/FlavorText

# Adjusted set_text to use an enum for flavor_text
func setup_death_report(death_type: String, death_name: String):
	death_stats.texture = load(str("res://Systems/HUD/Art/Death_By_",death_type,".png"))
	statistics.text = str("Time of duty: " + "\n" + str(WorldManager.CurrentDay) + " days" + "\n" + 
							"Cause of Death: " + "\n" + death_name)
	flavor_text.text = get_flavor_text(death_type)

func get_flavor_text(type: String) -> String:
	match type:
		"STARVATION":
			return "We found Gene Greyer’s body deep in the forest. It was clear starvation had taken him, but what struck us most were his final entries. They spoke of something watching him from the trees. The words were frantic, almost delirious, describing shapes in the darkness and whispers that seemed to answer his own. Whatever he was documenting out here, it seemed that, in the end, the forest itself became his final archive."
			
		"TVG":
			return "We found Gene Greyer’s body sprawled on the floor in front of an old, boxy vintage TV, its screen flickering with static. His face was frozen in a silent scream—eyes wide, mouth agape—and his skin was deathly pale, as if drained of life. The TV, which shouldn’t have worked, buzzed faintly, and his journal lay open nearby, the last entry describing strange whispers from the screen that grew louder each night, until he couldn’t escape them."
			
		"WG":
			return "We found Gene Greyer’s body deep in the forest, torn open by vicious claw marks that left his chest and abdomen shredded. Blood stained the ground, and his journal lay nearby, its final entries scrawled in desperation—frantic notes about a hulking creature with glowing eyes stalking him through the trees. Whatever it was, it found him first, leaving behind a scene of brutal violence and eerie silence."
			
	return "We found Gene Greyer’s body in his cabin, slumped in an old chair by the desk. There were no visible marks, no signs of struggle or injury. The room was untouched, and the air felt unnervingly still. His journal lay open, filled with fragmented notes, but nothing to explain his death. The cause remains a mystery, and something about the scene leaves an unsettling feeling, as if an unseen force had taken him."

func _on_restart_button_pressed() -> void:
	Load.load_scene(main_scene,"res://Systems/MainMenu/main_menu.tscn")
