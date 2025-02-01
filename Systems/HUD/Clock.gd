extends Control

@onready var hour_hand_sprite = $HourHandSprite
@onready var minute_hand_sprite = $MinuteHandSprite

const MAX_WORLD_TIME = 2400  # WorldTime ranges from 0 to 2399
const REAL_SECONDS_PER_DAY = 15 * 60  # 15 real minutes = 900 seconds
const WORLD_TIME_PER_SECOND = MAX_WORLD_TIME / REAL_SECONDS_PER_DAY  # 2400 / 900 = 2.67

var fractional_time: float = 0.0
var date_updated: bool = false

func _process(delta):
	# Increase fractional_time by the scaled amount of delta
	fractional_time += WORLD_TIME_PER_SECOND * delta
	
	# Convert the accumulated fractional_time to whole "time units"
	var time_to_add = int(fractional_time)
	fractional_time -= time_to_add
	
	WorldManager.WorldTime = (WorldManager.WorldTime + time_to_add) % MAX_WORLD_TIME
	
	update_display_time()
	update_day_part()
	update_clock_hands()  # <-- Call a function to update the hand rotations
	
	# When the clock resets to 0, handle date update
	if WorldManager.WorldTime == 0 and not date_updated:
		date_updated = true
		update_current_date()

func update_display_time():
	# total_hours goes from 0..23
	var total_hours = WorldManager.WorldTime / 100  
	# Convert the "minutes" portion (0..99) into real minutes (0..59.4)
	var minutes = (WorldManager.WorldTime % 100) * 0.6

	var am_pm = "AM"
	var display_hour = total_hours
	if display_hour == 0:
		display_hour = 12
	elif display_hour >= 12:
		am_pm = "PM"
		if display_hour > 12:
			display_hour -= 12

	# Format time as "H:MM AM/PM"
	WorldManager.DisplayTime = str(display_hour) + ":" + minute_to_string(int(minutes)) + " " + am_pm

func minute_to_string(minute: int) -> String:
	return "0" + str(minute) if minute < 10 else str(minute)

func update_day_part():
	var hour = WorldManager.WorldTime / 100  # 0..23

	if hour == 0:  # 12:00 AM
		WorldManager.DayPart = "Midnight"
	elif hour > 0 and hour < 5:
		WorldManager.DayPart = "Night"
	elif hour >= 5 and hour < 6:
		WorldManager.DayPart = "Dawn"
		GameManager.spawn_cooldown.stop()
	elif hour >= 6 and hour < 12:
		WorldManager.DayPart = "Morning"
	elif hour >= 12 and hour < 13:
		WorldManager.DayPart = "Noon"
	elif hour >= 13 and hour < 18:
		WorldManager.DayPart = "Afternoon"
	elif hour >= 18 and hour < 20:
		WorldManager.DayPart = "Dusk"
	else:
		WorldManager.DayPart = "Night"
		date_updated = false
		if GameManager.spawn_cooldown.is_stopped():
			GameManager.spawn_cooldown.start()

func update_current_date():
	WorldManager.CurrentDay += 1
	WorldManager.CurrentDate = "Day: " + str(WorldManager.CurrentDay)
	GameManager.difficulty *= 1.05

func update_clock_hands():
	# Convert WorldTime into hours and minutes
	# Example: 130 -> total_hours=1, remainder=30 => real minutes = 30*0.6=18
	var hour_24 = WorldManager.WorldTime / 100           # 0..23
	var hour_12 = hour_24 % 12                           # 0..11
	var minute_actual = (WorldManager.WorldTime % 100) * 0.6  # 0..59.4
	
	# --- Calculate standard clock angles ---
	# Standard clock logic: 
	#  - The minute hand makes a full circle (360°) in 60 minutes => 6° per minute
	#  - The hour hand makes a full circle (360°) in 12 hours => 30° per hour,
	#    plus it moves 0.5° per minute (30° / 60).
	var standard_minute_angle = minute_actual * 6.0
	var standard_hour_angle   = (hour_12 * 30.0) + (minute_actual * 0.5)
	
	# --- Shift angles so that 0° = down, 90° = left, 180° = up, 270° = right ---
	# In a typical "clock" representation:
	#   0° = top (12 o'clock), 90° = right, 180° = bottom (6 o'clock), 270° = left
	#
	# Since we want 0° to be down, we shift the standard angle by -180°:
	#   If standard is 180° (6 o'clock), we want 0° (down).
	#   final_angle = (standard_angle - 180) mod 360
	#
	# Alternatively, you can do final = (standard + 180) mod 360 if you reason in the opposite direction.
	# We just need the end result: standard=180° => final=0°

	var final_hour_angle   = shift_angle_to_down(standard_hour_angle)
	var final_minute_angle = shift_angle_to_down(standard_minute_angle)

	# Apply the rotation (in degrees) to the sprites
	hour_hand_sprite.rotation_degrees = final_hour_angle
	minute_hand_sprite.rotation_degrees = final_minute_angle

func shift_angle_to_down(angle):
	return (int(angle) - 180) % 360
