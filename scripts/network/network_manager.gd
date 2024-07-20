extends Node

signal tick_command_received(tick_data: TickData)
signal join_command_received(player_data: PlayerData, is_local: bool)
signal load_players_command_received(players_data: Array[PlayerData])
signal chat_command_received(player_id: int, message: String)
signal move_command_received(player_id: int, move_data: MoveData)
signal kick_command_received(player_id: int)

var _socket = WebSocketPeer.new()

var _local_player_id: int;
var _local_player_data: PlayerData;

func _ready():
	# TODO: get token and id from auth
	var token = "123456"
	_local_player_id = 0

	var websocket_base_url = Env.get_variable("WEBSOCKET_URL")
	var url = "%sjoin/%s/" % [websocket_base_url, token]
	_socket.connect_to_url(url)

func _process(_delta):
	_socket.poll()

	var state = _socket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass

		WebSocketPeer.STATE_OPEN:
			while _socket.get_available_packet_count():
				var packet =  _socket.get_packet()
				var message = packet.get_string_from_utf8()

				_parse_message(message)

		WebSocketPeer.STATE_CLOSING:
			pass

		WebSocketPeer.STATE_CLOSED:
			var code = _socket.get_close_code()
			var reason = _socket.get_close_reason()
			print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			set_process(false)

func _parse_message(message: String):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(message)

	var data_received = json_object.data
	var from = data_received.get('from')
	var command = data_received.get('command')
	var payload = data_received.get('payload')

	_parse_command(command, from, payload)

func _parse_command(command, from, payload):
	match command:
		"Tick":
			_process_tick_command(payload)
		"Join":
			_process_join_command(payload)
		"LoadPlayers":
			_process_load_players_command(payload)
		"Chat":
			_process_chat_command(from, payload)
		"Move":
			_process_move_command(from, payload)
		"Kick":
			_process_kick_command(payload)
		_:
			print("Command: ", command)
			print("Payload:", payload)

func _process_tick_command(payload):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(payload)
	var raw_data = json_object.data

	var tick_data = TickData.new(raw_data)
	tick_command_received.emit(tick_data)

func _process_join_command(payload):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(payload)
	var raw_data = json_object.data

	var player_data = PlayerData.new(raw_data)

	if _local_player_id == 0:
		_local_player_id = player_data.id

	var is_local = player_data.id == _local_player_id
	if is_local:
		_local_player_data = player_data

	join_command_received.emit(player_data, is_local)

func _process_load_players_command(payload):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(payload)

	var players_data: Array[PlayerData] = []
	for d in json_object.data:
		players_data.append(PlayerData.new(d))

	load_players_command_received.emit(players_data)

func _process_chat_command(from, payload):
	var player_id = int(from.get("PlayerId"))
	chat_command_received.emit(player_id, payload)

func _process_move_command(from, payload):
	var player_id = int(from.get("PlayerId"))

	var json_object = JSON.new()
	var _parse_err = json_object.parse(payload)

	var move_data = MoveData.new(json_object.data)
	move_command_received.emit(player_id, move_data)

func _process_kick_command(payload):
	var player_id = int(payload)
	kick_command_received.emit(player_id)

func send_chat_command(message):
	var chat_command = """{
		"to": "All",
		"command": "Chat",
		"payload": "%s"
	}""" % [message.json_escape()]
	send_command(chat_command)

func send_move_command(position: Vector2, direction: String, animation: String):
	var x = position.x
	var y = position.y
	var position_string = """{
		"x": %.5f,
		"y": %.5f
	}""" % [x, y] if position else "null"

	var move_payload = """{
		"position": %s,
		"direction": "%s",
		"animation": "%s"
	}""" % [position_string, direction, animation]

	var move_command = """{
		"to": "All",
		"command": "Move",
		"payload": "%s"
	}""" % [move_payload.json_escape()]

	send_command(move_command)

func send_command(command: String):
	command = command.replace('\n', '')
	command = command.replace('\t', '')
	command = command.replace('\\n', '')
	command = command.replace('\\t', '')
	print(command)

	var state = _socket.get_ready_state()
	if state != WebSocketPeer.STATE_OPEN:
		return

	_socket.send_text(command)

func get_player_name(player_id):
	if player_id == _local_player_id:
		return _local_player_data.get("name")

	return NetworkPlayerFactory.get_remote_player_name(player_id)
