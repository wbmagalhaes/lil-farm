extends Node

var _base_network_player = 1
var _spawned_players: Dictionary = {}

func _ready():
	NetworkManager.connect('join_command_received', self._on_join_command_received)
	NetworkManager.connect('load_players_command_received', self._on_load_players_command_received)
	NetworkManager.connect('kick_command_received', self._on_kick_command_received)

func spawn_network_player(player_data: Dictionary):
	var player_id = int(player_data.get("id"))

	# TODO: spawn player obj
	var player_name = player_data.get("name")
	print("Spawn %s" % player_name)

	_spawned_players[player_id] = player_data

func remove_network_player(player_id: int):
	var player_data = _spawned_players.get(player_id);
	if not player_data:
		return

	# TODO: remove player obj
	var player_name = player_data.get("name")
	print("Remove %s" % player_name)

	_spawned_players.erase(player_id)

func _on_join_command_received(player_data: Dictionary, is_local_player: bool):
	if not is_local_player:
		spawn_network_player(player_data)

func _on_load_players_command_received(players_data: Array):
	for player_data in players_data:
		spawn_network_player(player_data)

func _on_kick_command_received(player_id: int):
	remove_network_player(player_id)
