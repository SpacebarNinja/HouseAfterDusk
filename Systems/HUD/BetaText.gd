extends Label

## PLEASE CHANGE VERSION HERE
var CURRENT_VERSION := '0.21.0'
#------------------------------------------

const weekday_names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
const month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	var datetime = Time.get_datetime_dict_from_system()
	var weekday = weekday_names[datetime.weekday]
	var month = month_names[datetime.month - 1]
	var hour = datetime.hour % 12
	if hour == 0: hour = 12
	var ampm = "pm" if datetime.hour >= 12 else "am"
	var time_str = str(hour) + ":" + ("%02d" % datetime.minute) + ampm
	var date_str = weekday + ", " + month + " " + str(datetime.day) + " " + str(datetime.year) + ", " + time_str
	
	text = "House After Dusk - Beta v" + CURRENT_VERSION + " | FPS: " + str(fps) + "\n" + date_str
