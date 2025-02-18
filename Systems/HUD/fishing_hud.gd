extends CanvasLayer

@onready var hud = get_tree().get_first_node_in_group("Hud")
@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var protoset = preload("res://Systems/Inventory/Backpack/Consumables.tres")

@onready var background_bar = $BackgroundBar
@onready var progress_meter = $ProgressMeter
@onready var success_bar = $SuccessBar
@onready var fishing_hook = $FishingHook
@onready var fishing_area = $FishingHook/FishingArea

@onready var chance_timer = $ChanceTimer
@onready var duration_timer = $DurationTimer

@export var move_chance: int = 6        #1-10 = (10% - 100%), 6 = 60%
@export var gravity: int = 1            #drop speed
@export var hook_strength: int = 3      #input stength
@export var progress_speed: int = 0.5   #speed of success bar

var move_bar: bool = false
var found_hook: bool = false
var new_bar_location: Vector2
var hook_level = -320

const HOOK_MIN = -320
const HOOK_MAX = 0
const BAR_UPPER = 132
const BAR_LOWER = 448

func _process(delta):
	if hud.current_hud == "Fishing":
		hook_level = clamp(hook_level, HOOK_MIN, HOOK_MAX)
		
		hook_level += gravity
		fishing_area.position.y = hook_level + 344
		fishing_hook.texture.margin = Rect2i(0, hook_level, 0, 0)
		
		if Input.is_action_pressed("Use"):
			hook_level -= hook_strength
			
		if move_bar:
			set_success_bar(new_bar_location, delta)
		
		if found_hook:
			progress_meter.value += progress_speed
		else:
			progress_meter.value -= progress_speed/2

func set_success_bar(new_position: Vector2, delta):
	if success_bar.position != new_bar_location:
		success_bar.position = lerp(success_bar.position, new_position, delta)
	else:
		move_bar = false

func _on_chance_timer_timeout():
	var chance = randi_range(0,10)
	print("ChanceToMove: ", chance)
	if chance >= move_chance:
		new_bar_location = Vector2(256,randi_range(BAR_UPPER, BAR_LOWER))
		move_bar = true
	
func _on_duration_time_timeout():
	reset()

func _on_success_area_entered(area):
	found_hook = true
	print("FoundHook")

func _on_success_area_exited(area):
	found_hook = false
	print("HooKLost")

func _on_progress_meter_value_changed(value):
	if value >= 100:
		var randomizer = randi_range(1, 100)
		var item_id = ""
		
		if randomizer <= 2:  # 2% chance
			item_id = "trash"
		elif randomizer <= 7:  # 5% chance
			item_id = "tentacle"
		elif randomizer <= 19:  # 12% chance
			item_id = "crab"
		elif randomizer <= 49:  # 30% chance
			item_id = "seaweed"
		else:  # 51% chance (remaining)
			item_id = "fish"
		
		# Add item to the inventory
		if backpack:
			backpack.add_inventory_item(item_id, 1)
			reset()

func reset():
	hud.current_display("Main")
	hook_level = -320
	progress_meter.value = 0
	chance_timer.stop()
	duration_timer.stop()
