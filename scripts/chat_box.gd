extends CanvasLayer

@onready var input_field = $Panel/VBoxContainer/LineEdit
@onready var chat_log = $Panel/VBoxContainer/RichTextLabel

var _players = {
	1: "Jorge",
	2: "Mario",
	3: "Carlos",
	4: "Pedro",
	5: "Gabriel",
	6: "Matheus",
	7: "Luiz",
	8: "Rafael",
	9: "Felipe",
	10: "Bruno",
}

func _ready():
	chat_log.set_text("")
	input_field.connect("text_submitted", self.on_text_submitted)
	NetworkManager.connect('join_command_recieved', self._on_join_command_recieved)
	NetworkManager.connect('chat_command_recieved', self._on_chat_command_recieved)
	NetworkManager.connect('kick_command_recieved', self._on_kick_command_recieved)

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

func _on_join_command_recieved(player_data: Dictionary, _is_local_player: bool):
	add_message("System", "%s joined the game." % player_data.name)

func _on_chat_command_recieved(player_id: int, message: String):
	var player_name = _players.get(player_id)
	add_message(player_name, message)

func _on_kick_command_recieved(player_id: int):
	var player_name = _players.get(player_id)
	add_message("System", "%s left the game." % player_name)
