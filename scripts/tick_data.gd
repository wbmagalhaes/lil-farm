class_name TickData

var time: Dictionary
var delta_time: float

func _init(json_data: Dictionary):
	var datetime_string = json_data.get("time")
	self.time = Time.get_datetime_dict_from_datetime_string(datetime_string, false)
	self.delta_time = int(json_data.get("delta_time"))
