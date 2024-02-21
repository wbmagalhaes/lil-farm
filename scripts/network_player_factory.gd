extends Node

# TODO: find a better way
@onready var _level_root = get_tree().get_root().get_child(2)
const _base_remote_player = preload("res://scenes/RemotePlayer.tscn")
var _remote_players: Dictionary = {}

signal player_added(player_name: String, join_player: bool)
signal player_removed(player_name: String)

func _ready():
	NetworkManager.connect('join_command_received', self._on_join_command_received)
	NetworkManager.connect('load_players_command_received', self._on_load_players_command_received)
	NetworkManager.connect('kick_command_received', self._on_kick_command_received)

func spawn_network_player(player_data: Dictionary, join_player: bool):
	var player_id = int(player_data.get("id"))
	var remote_player: RemotePlayer = _base_remote_player.instantiate()
	remote_player.initialize(player_data)

	_level_root.add_child(remote_player)

	_remote_players[player_id] = remote_player
	player_added.emit(remote_player.player_name, join_player)

func remove_network_player(player_id: int):
	var remote_player: RemotePlayer = _remote_players.get(player_id);
	if not remote_player:
		return

	player_removed.emit(remote_player.player_name)

	remote_player.destroy()
	_remote_players.erase(player_id)

func get_remote_player_name(player_id: int):
	var remote_player: RemotePlayer = _remote_players.get(player_id);
	if not remote_player:
		return "INVALID"

	return remote_player.player_name

func _on_join_command_received(player_data: Dictionary, local_player: bool):
	if not local_player:
		spawn_network_player(player_data, true)

func _on_load_players_command_received(players_data: Array):
	for player_data in players_data:
		spawn_network_player(player_data, false)

func _on_kick_command_received(player_id: int):
	remove_network_player(player_id)
