extends CanvasLayer

@onready var input_field = $Panel/VBoxContainer/LineEdit
@onready var chat_log = $Panel/VBoxContainer/RichTextLabel

func _ready():
	chat_log.set_text("")
	input_field.connect("text_submitted", self.on_text_submitted)
	NetworkManager.connect('chat_command_received', self._on_chat_command_received)
	
	NetworkManager.connect('join_command_received', self._on_join_command_received)
	NetworkPlayerFactory.connect('player_added', self._on_player_added)
	NetworkPlayerFactory.connect('player_removed', self._on_player_removed)

func _process(_delta):
	pass

func add_message(from: String, body: String):
	if chat_log.get_total_character_count() > 1:
		chat_log.add_text('\n')

	var time = Time.get_datetime_dict_from_system()
	var time_string: String = "%02d/%02d/%d %02d:%02d:%02d" % [time.day, time.month, time.year, time.hour, time.minute, time.second];

	var message: String = "[%s - %s]: %s" % [time_string, from, body]
	chat_log.add_text(message)

func on_text_submitted(text):
	if not text:
		return

	NetworkManager.send_chat_command(text)

	input_field.release_focus()
	input_field.text = ''

func _on_chat_command_received(player_id: int, message: String):
	var player_name = NetworkManager.get_player_name(player_id)
	add_message(player_name, message)

func _on_join_command_received(player_data: Dictionary, local_player: bool):
	if local_player:
		var player_name = player_data.get("name")
		add_message("System", "Welcome, %s!" % player_name)

func _on_player_added(player_name: String, join_player: bool):
	if join_player:
		add_message("System", "%s joined the game." % player_name)

func _on_player_removed(player_name: String):
	add_message("System", "%s left the game." % player_name)
