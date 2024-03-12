class_name Player
extends CharacterBody2D

@export var speed: float = 40
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pick_range: PickupRange = $pick_up_range
@onready var inventory: Inventory = $"../UI/inventory_dialog"

var _current_position: Vector2
var _current_direction: String
var _current_animation: String

var _last_sent_position: Vector2
var _last_sent_direction: String
var _last_sent_animation: String

const MOVE_COMMAND_DIST_THRESHOLD = 0.5

func _ready():
	_current_position = Vector2(0, 0)
	_current_direction = "Down"
	_current_animation = "idle"

	pick_range.pick_item.connect(self._on_pick_item)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func set_animation():
	if velocity.y < 0:
		animation_player.play("run_up")
		_current_direction = "Up"
		_current_animation = "run_up"
	elif velocity.y > 0:
		animation_player.play("run_down")
		_current_direction = "Down"
		_current_animation = "run_down"
	elif velocity.x < 0:
		animation_player.play("run_left")
		_current_direction = "Left"
		_current_animation = "run_left"
	elif velocity.x > 0:
		animation_player.play("run_right")
		_current_direction = "Right"
		_current_animation = "run_right"
	else:
		animation_player.play("idle")
		_current_animation = "idle"

func _physics_process(_delta: float) -> void:
	get_input()
	set_animation()
	move_and_slide()

	_current_position = get_position()
	send_move_update()

func send_move_update():
	if move_command_is_diff():
		NetworkManager.send_move_command(
			_current_position,
			_current_direction,
			_current_animation,
		)

		_last_sent_position = _current_position
		_last_sent_direction = _current_direction
		_last_sent_animation = _current_animation

func move_command_is_diff() -> bool:
	if _last_sent_position == null or _last_sent_direction == null or _last_sent_animation == null:
		return true

	if _current_animation != _last_sent_animation:
		return true

	if _current_direction != _last_sent_direction:
		return true

	var delta_pos_sq = (_current_position - _last_sent_position).length_squared()
	if delta_pos_sq > MOVE_COMMAND_DIST_THRESHOLD * MOVE_COMMAND_DIST_THRESHOLD:
		return true

	return false

func _on_pick_item(item_pickup: ItemPickup):
	var item = item_pickup.get_item()
	# TODO: send the command to server
	# TODO: await for server response to update inventory
	if inventory.add_item(item):
		item_pickup.set_disabled(true)
		item.visible = false
