extends Control

var HUMANOID = {
	Descriptions = {
		"height": [],
		"gender": [],
		"clothing": [],
		"features": [],
		"other": [],
	},
	Behaviors = {
		"state_1": [],
		"state_2": [],
		"state_3": [],
		"state_4": [],
	},
	Methods = {
		"methods": []
	}
}

var MONSTER = {
	Descriptions = {
		"height": ["Appears to be a giant", "Appears to be a tiny", "Appears to be a human-sized"],
		"shape": ["bipedal creature", "four-legged creature", "blob-like creature", "shapeshifting creature"],
		"features": ["with scales", "with fur", "with multiple limbs", "with gelatinous skin"]
	},
	Behaviors = {
		"action": ["is walking slowly", "is running fast", "is standing still"],
		"reaction": ["looks scared", "seems aggressive", "appears confused"]
	},
	Methods = {
		"methods": ["Method 1 for Monster", "Method 2 for Monster"]
	}
}

var OBJECT = {
	Descriptions = {
		"size": ["Appears to be a large", "Appears to be a small"],
		"shape": ["cylinder", "cube", "box", "circular", "triangular"],
		"type": ["container", "weapon", "tool", "unknown"],
		"location": ["in the kitchen", "in the living room", "in the bathroom", "in the garden", "in the bedroom"]
	},
	Behaviors = {
		"interaction": ["emits a strange glow", "makes a humming sound", "feels warm to the touch"],
		"state": ["is in perfect condition", "is slightly damaged", "is falling apart"]
	},
	Methods = {
		"methods": ["Method 1 for Object", "Method 2 for Object"]
	}
}

var UNKNOWN = {
	Descriptions = {
		"voices": ["sounds like a loud scream", "sounds like whispering", "unsettling sounds"],
		"location": ["near the well", "in the cabin", "in the attic", "near the cave"],
		"ambience": ["with unknown clothes"]
	},
	Behaviors = {
		"phenomenon": ["appears out of nowhere", "vanishes suddenly", "changes shape"],
		"effect": ["causes a chill in the air", "makes you feel uneasy", "induces a sense of dread"]
	},
	Methods = {
		"methods": ["Method 1 for Unknown", "Method 2 for Unknown"]
	}
}

enum Category { HUMANOID, MONSTER, OBJECT, UNKNOWN }
enum Sub_category { Descriptions, Behaviors, Methods }

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var anim_sprite = $AnimatedSprite2D
@onready var category_buttons = $CategoryButtons
@onready var turn_left = $TurnLeft
@onready var turn_right = $TurnRight
@onready var journal_open_sfx = $JournalOpenSFX
@onready var journal_close_sfx = $JournalCloseSFX
@onready var black_overlay = $"../../BGProcessing/BlackOverlay"

@export var page_amount: int = 3
var page_number: int
var pages = []
var is_open: bool = false
var can_edit: bool = false
var page_scene_path = "res://Systems/Journal/Page.tscn"

var quill = load("res://Assets/Cursors/Quill.png")
var cursor = load("res://Assets/Cursors/Cursor.png")

@export var open_y_position: float = 320.0
@export var closed_y_position: float = 400.0
@export var lerp_speed: float = 5.0
var target_y_position: float = 400.0
var target_opacity: float = 0.0 
var black_overlay_target_opacity: float = 0.0

var open_journal_state: bool = false
var is_animating: bool = false

func _ready():
	self.hide()
	hide_all_children(anim_sprite)
	hide_all_children(category_buttons)
	turn_left.hide()
	turn_right.hide()

	for i in range(page_amount):
		add_page()
	page_number = page_amount
	access_labels()


func _process(delta):
	position.y = lerp(position.y, target_y_position, lerp_speed * delta)
	modulate.a = lerp(modulate.a, target_opacity, lerp_speed * delta)
	black_overlay.modulate.a = lerp(black_overlay.modulate.a, black_overlay_target_opacity, lerp_speed * delta)

	if modulate.a <= 0.01 and not is_open:
		self.hide()

	# Handle input for toggling the journal
	if Input.is_action_just_pressed("OpenJournal"):
		open_journal_state = not open_journal_state

	if not is_animating:
		if open_journal_state and not is_open:
			start_open_journal_animation()
		elif not open_journal_state and is_open:
			start_close_journal_animation()
			
	var current_page = get_current_page()
	if current_page:
		var name_editor = current_page.get_node("NameEditor")
		var notes_editor = current_page.get_node("NotesEditor")
		if not name_editor.has_focus() and not notes_editor.has_focus():
			if Input.is_action_just_pressed("Escape") and is_open and not is_animating:
				open_journal_state = false

	if not is_open:
		hide_all_children(category_buttons)

func start_open_journal_animation():
	if not HudManager.journal_visible:
		return
		
	is_animating = true
	black_overlay.show()
	journal_open_sfx.play()
	self.show()
	anim_sprite.speed_scale = 1
	anim_sprite.play("OpenJournal")
	anim_sprite.connect("animation_finished", Callable(self, "_on_anim_sprite_animation_finished_open"))
	Input.set_custom_mouse_cursor(quill, Input.CURSOR_ARROW)
	
	target_y_position = open_y_position
	target_opacity = 1.0
	black_overlay_target_opacity = 1


func _on_anim_sprite_animation_finished_open():
	show_all_children(category_buttons)
	anim_sprite.disconnect("animation_finished", Callable(self, "_on_anim_sprite_animation_finished_open"))
	is_open = true
	is_animating = false


func start_close_journal_animation():
	is_animating = true
	journal_close_sfx.play()
	hide_all_children(category_buttons)
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW)

	for page in pages:
		page.hide()
	turn_left.hide()
	turn_right.hide()
	anim_sprite.speed_scale = 1.4
	anim_sprite.play_backwards("OpenJournal")
	anim_sprite.connect("animation_finished", Callable(self, "_on_anim_sprite_animation_finished_close"))

	target_y_position = closed_y_position
	target_opacity = 0.0
	black_overlay_target_opacity = 0


func _on_anim_sprite_animation_finished_close():
	self.hide()
	is_open = false
	player.set_walk_speed(80)
	is_animating = false
	anim_sprite.disconnect("animation_finished", Callable(self, "_on_anim_sprite_animation_finished_close"))


func hide_all_children(node):
	for child in node.get_children():
		child.hide()

func show_all_children(node):
	for child in node.get_children():
		child.show()

func add_page():
	var page_scene = load(page_scene_path)
	var page_instance = page_scene.instantiate()
	pages.append(page_instance)
	add_child(page_instance)
	page_instance.hide()

func set_can_edit(value: bool):
	can_edit = value
	for child in get_children():
		if child.has_method("set_can_edit"):
			child.set_can_edit(value)

func access_labels():
	for page in pages:
		pass # removed this to remove warning

func get_current_page():
	if page_number > 0 and page_number <= pages.size():
		return pages[page_number - 1]
	return null

func show_current_page():
	for i in range(pages.size()):
		if i == page_number - 1:
			pages[i].show()
		else:
			pages[i].hide()
	update_navigation_buttons()

func update_navigation_buttons():
	if page_number > 1:
		turn_right.show()
	else:
		turn_right.hide()

	if page_number < pages.size():
		turn_left.show()
	else:
		turn_left.hide()

func queue_free_children(node):
	for child in node.get_children():
		child.queue_free()

func humanoid_pressed():
	hide_all_children(category_buttons)
	show_all_children(anim_sprite)
	show_current_page()
	update_navigation_buttons()
	var current_page = get_current_page()
	if current_page:
		current_page.set_category_data(HUMANOID)
		set_can_edit(true)

func monster_pressed():
	hide_all_children(category_buttons)
	show_all_children(anim_sprite)
	show_current_page()
	update_navigation_buttons()
	var current_page = get_current_page()
	if current_page:
		current_page.set_category_data(MONSTER)
		set_can_edit(true)

func object_pressed():
	hide_all_children(category_buttons)
	show_all_children(anim_sprite)
	show_current_page()
	update_navigation_buttons()
	var current_page = get_current_page()
	if current_page:
		current_page.set_category_data(OBJECT)
		set_can_edit(true)

func unknown_pressed():
	hide_all_children(category_buttons)
	show_all_children(anim_sprite)
	show_current_page()
	update_navigation_buttons()
	var current_page = get_current_page()
	if current_page:
		current_page.set_category_data(UNKNOWN)
		set_can_edit(true)


func next_page():
	if page_number < pages.size() and not is_animating:
		is_animating = true
		journal_open_sfx.play()
		page_number += 1
		anim_sprite.play_backwards("FlipPage")
		for page in pages:
			page.hide()
		await anim_sprite.animation_finished
		var current_page = get_current_page()
		if current_page:
			show_current_page()
		update_navigation_buttons()
		is_animating = false

func previous_page():
	if page_number > 1 and not is_animating:
		is_animating = true
		journal_open_sfx.play()
		page_number -= 1
		anim_sprite.play("FlipPage")
		for page in pages:
			page.hide()
		await anim_sprite.animation_finished
		var current_page = get_current_page()
		if current_page:
			show_current_page()
		update_navigation_buttons()
		is_animating = false

func new_word(main_category: String, category: String, subcategory: String, word: String) -> void:
	print("Added New Words")
	if main_category == 'HUMANOID':
		HUMANOID[category][subcategory].append(word)
	if main_category == 'MONSTER':
		MONSTER[category][subcategory].append(word)
	if main_category == 'OBJECT':
		OBJECT[category][subcategory].append(word)
	if main_category == 'UNKNOWN':
		UNKNOWN[category][subcategory].append(word)
