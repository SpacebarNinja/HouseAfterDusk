extends Label

func _process(_delta):
	var events = InputMap.action_get_events("OpenJournal")
	if events.size() > 0:
		text = events[0].as_text().trim_suffix(' (Physical)')
	else:
		text = ''
