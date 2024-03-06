extends Node

const WEBSOCKET_URL = "ws://127.0.0.1:8080/join/"

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

	var url = "%s%s" % [WEBSOCKET_URL, token]
	_socket.connect_to_url(url)

func _process(_delta):
	_socket.poll()

	var state = _socket.get_ready_state()

	if state == WebSocketPeer.STATE_CONNECTING:
		# print("Connecting...")
		pass

	elif state == WebSocketPeer.STATE_OPEN:
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
		set_process(false)

func _parse_payload(payload: String):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(payload)

	var data_received = json_object.data
	var from = data_received.get('from')
	var command = data_received.get('command')
	var body = data_received.get('body')

	_parse_command(command, from, body)

func _parse_command(command, from, body):
	if command == "Tick":
		_process_tick_command(body)
	elif command == "Join":
		_process_join_command(body)
	elif command == "LoadPlayers":
		_process_load_players_command(body)
	elif command == "Chat":
		_process_chat_command(from, body)
	elif command == "Move":
		_process_move_command(from, body)
	elif command == "Kick":
		_process_kick_command(body)
	else:
		print("Command: ", command)
		print("Body:", body)

func _process_tick_command(body):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)
	var raw_data = json_object.data

	var tick_data = TickData.new(raw_data)
	tick_command_received.emit(tick_data)

func _process_join_command(body):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)
	var raw_data = json_object.data

	var player_data = PlayerData.new(raw_data)

	if _local_player_id == 0:
		_local_player_id = player_data.id

	var is_local = player_data.id == _local_player_id
	if is_local:
		_local_player_data = player_data

	join_command_received.emit(player_data, is_local)

func _process_load_players_command(body):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)

	var players_data: Array[PlayerData] = []
	for d in json_object.data:
		players_data.append(PlayerData.new(d))

	load_players_command_received.emit(players_data)

func _process_chat_command(from, body):
	var player_id = int(from.get("PlayerId"))
	chat_command_received.emit(player_id, body)

func _process_move_command(from, body):
	var player_id = int(from.get("PlayerId"))

	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)

	var move_data = MoveData.new(json_object.data)
	move_command_received.emit(player_id, move_data)

func _process_kick_command(body):
	var player_id = int(body)
	kick_command_received.emit(player_id)

func send_chat_command(message):
	var state = _socket.get_ready_state()
	if state != WebSocketPeer.STATE_OPEN:
		return

	var chat_command = """{
		"to": "All",
		"command": "Chat",
		"body": "%s"
	}""" % [message.json_escape()]
	_socket.send_text(chat_command)

func send_move_command(position: Vector2, direction: String, animation: String):
	var state = _socket.get_ready_state()
	if state != WebSocketPeer.STATE_OPEN:
		return

	var position_string = """{
		"x": %s,
		"y": %s
	}""" % [position.x, position.y] if position else "null"

	var move_body = """{
		"position": %s,
		"direction": "%s",
		"animation": "%s"
	}""" % [position_string, direction, animation]

	var move_command = """{
		"to": "All",
		"command": "Move",
		"body": "%s"
	}""" % [move_body.json_escape()]

	_socket.send_text(move_command)

func get_player_name(player_id):
	if player_id == _local_player_id:
		return _local_player_data.get("name")

	return NetworkPlayerFactory.get_remote_player_name(player_id)

