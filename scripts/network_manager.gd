extends Node

var websocket_url = "ws://localhost:8080/ws/"

signal join_command_received(player_data: Dictionary, is_local_player: bool)
signal load_players_command_received(players_data: Array)
signal chat_command_received(player_id: int, message: String)
signal kick_command_received(player_id: int)

var _socket = WebSocketPeer.new()

var _local_player_id: int;
var _connected_players: Dictionary = {}

func _ready():
	_local_player_id = randi_range(1, 10)

	var socket_url = "%s%d" % [websocket_url, _local_player_id]
	_socket.connect_to_url(socket_url)

func _process(_delta):
	_socket.poll()
	var state = _socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		while _socket.get_available_packet_count():
			var packet =  _socket.get_packet()
			var payload = packet.get_string_from_utf8()

			_parse_payload(payload)

	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _socket.get_close_code()
		var reason = _socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func _parse_payload(payload: String):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(payload)

	var data_received = json_object.data
	var from = data_received.get('from')
	var command = data_received.get('command')
	var body = data_received.get('body')

	_parse_command(command, from, body)

func _parse_command(command, from, body):
	if command == "Join":
		_process_join_command(body)
	elif command == "LoadPlayers":
		_process_load_players_command(body)
	elif command == "Chat":
		_process_chat_command(from, body)
	elif command == "Kick":
		_process_kick_command(body)
	else:
		print("Command: ", command)
		print("Body:", body)

func _process_join_command(body):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)
	var player_data = json_object.data

	var player_id = int(player_data.get("id"))
	_connected_players[player_id] = player_data

	var is_local = player_id == _local_player_id
	join_command_received.emit(player_data, is_local)

func _process_load_players_command(body):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)
	var players_data = json_object.data

	var remote_players = []
	for player_data in players_data:
		var player_id = int(player_data.get("id"))
		_connected_players[player_id] = player_data

		var is_local = player_id == _local_player_id
		if not is_local:
			remote_players.append(player_data)

	load_players_command_received.emit(remote_players)

func _process_chat_command(from, body):
	var player_id = int(from.get("PlayerId"))
	chat_command_received.emit(player_id, body)

func _process_kick_command(body):
	var player_id = int(body)
	kick_command_received.emit(player_id)
	_connected_players.erase(player_id)

func send_chat_command(message):
	var chat_command = """
		{
			"to": "All",
			"command": "Chat",
			"body": "%s"
		}
	""" % [message]
	_socket.send_text(chat_command)
