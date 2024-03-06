extends Node

# TODO: find a better way
@onready var _level_root = get_tree().get_root().get_child(2)
const _base_remote_player = preload("res://scenes/network/remote_player.tscn")
var _remote_players: Dictionary = {}

signal player_added(player_name: String, join_player: bool)
signal player_removed(player_name: String)

func _ready():
	NetworkManager.join_command_received.connect(self._on_join_command_received)
	NetworkManager.load_players_command_received.connect(self._on_load_players_command_received)
	NetworkManager.move_command_received.connect(self._on_move_command_received)
	NetworkManager.kick_command_received.connect(self._on_kick_command_received)

func spawn_network_player(player_data: PlayerData, join_player: bool):
	var remote_player: RemotePlayer = _base_remote_player.instantiate()
	remote_player.initialize(player_data)

	_level_root.add_child(remote_player)

	_remote_players[player_data.id] = remote_player
	player_added.emit(player_data.name, join_player)

func remove_network_player(player_id: int):
	var remote_player: RemotePlayer = _remote_players.get(player_id);
	if not remote_player:
		return

	player_removed.emit(remote_player.data.name)

	remote_player.destroy()
	_remote_players.erase(player_id)

func get_remote_player_name(player_id: int):
	var remote_player: RemotePlayer = _remote_players.get(player_id);
	if not remote_player:
		return "INVALID"

	return remote_player.data.name

func _on_join_command_received(player_data: PlayerData, local_player: bool):
	if not local_player:
		spawn_network_player(player_data, true)

func _on_load_players_command_received(players_data: Array[PlayerData]):
	for player_data in players_data:
		spawn_network_player(player_data, false)

func _on_move_command_received(player_id: int, move_data: MoveData):
	var remote_player: RemotePlayer = _remote_players.get(player_id)
	if remote_player == null:
		return

	remote_player.update_position(move_data.position)
	remote_player.update_direction(move_data.direction)
	remote_player.update_animation(move_data.animation)

func _on_kick_command_received(player_id: int):
	remove_network_player(player_id)
