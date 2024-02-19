extends Node

@export var websocket_url = "ws://localhost:8080/ws/"

signal join_command_recieved(player_data: Dictionary)
signal chat_command_recieved(player_id: int, message: String)
signal kick_command_recieved(player_id: int)

var _socket = WebSocketPeer.new()

func _ready():
	var rng = randi_range(0, 10)
	var url = "%s%d" % [websocket_url, rng]
	_socket.connect_to_url(url, TLSOptions.client_unsafe())

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
	if command == "Chat":
		_process_chat_command(from, body)
	elif command == "Join":
		_process_join_command(body)
	elif command == "Kick":
		_process_kick_command(body)
	else:
		print("Command: ", command)
		print("Body:", body)

func _process_join_command(body):
	var json_object = JSON.new()
	var _parse_err = json_object.parse(body)
	join_command_recieved.emit(json_object.data)

func _process_chat_command(from, body):
	var player_id = int(from.get("PlayerId"))
	chat_command_recieved.emit(player_id, body)

func _process_kick_command(body):
	var player_id = int(body)
	kick_command_recieved.emit(player_id)

func send_chat_command(message):
	var chat_command = """
		{
			"to": "All",
			"command": "Chat",
			"body": "%s"
		}
	""" % [message]
	_socket.send_text(chat_command)
